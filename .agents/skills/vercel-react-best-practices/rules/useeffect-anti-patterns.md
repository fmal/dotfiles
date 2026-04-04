---
title: useEffect Anti-Patterns
impact: MEDIUM
impactDescription: avoids extra render passes, stale state, and cascade bugs
tags: useeffect, anti-pattern, hooks, performance
---

## useEffect Anti-Patterns

Effects are an escape hatch from React. If there is no external system involved, you shouldn't need an Effect.

### 1. Redundant State for Derived Values

**Incorrect: extra state + effect for derived value**

```tsx
function Form() {
  const [firstName, setFirstName] = useState('First')
  const [lastName, setLastName] = useState('Last')
  const [fullName, setFullName] = useState('')

  useEffect(() => {
    setFullName(firstName + ' ' + lastName)
  }, [firstName, lastName])

  return <p>{fullName}</p>
}
```

**Correct: calculate during render**

```tsx
function Form() {
  const [firstName, setFirstName] = useState('First')
  const [lastName, setLastName] = useState('Last')
  const fullName = firstName + ' ' + lastName

  return <p>{fullName}</p>
}
```

### 2. Filtering/Transforming Data in Effect

**Incorrect: effect to transform data**

```tsx
function TodoList({ todos, filter }: Props) {
  const [filteredTodos, setFilteredTodos] = useState(todos)

  useEffect(() => {
    setFilteredTodos(todos.filter(t => t.status === filter))
  }, [todos, filter])
}
```

**Correct: derive during render with useMemo**

```tsx
function TodoList({ todos, filter }: Props) {
  const filteredTodos = useMemo(
    () => todos.filter(t => t.status === filter),
    [todos, filter]
  )
}
```

### 3. Resetting State on Prop Change

**Incorrect: effect to reset state**

```tsx
function ProfilePage({ userId }: { userId: string }) {
  const [comment, setComment] = useState('')

  useEffect(() => {
    setComment('')
  }, [userId])
}
```

**Correct: key prop forces remount**

```tsx
function ProfilePage({ userId }: { userId: string }) {
  return <Profile userId={userId} key={userId} />
}

function Profile({ userId }: { userId: string }) {
  const [comment, setComment] = useState('')
  // comment resets automatically when userId changes
}
```

### 4. Event-Specific Logic in Effect

**Incorrect: event modeled as state + effect**

```tsx
function Form() {
  const [submitted, setSubmitted] = useState(false)
  const theme = useContext(ThemeContext)

  useEffect(() => {
    if (submitted) {
      post('/api/register')
      showToast('Registered', theme)
    }
  }, [submitted, theme])

  return <button onClick={() => setSubmitted(true)}>Submit</button>
}
```

**Correct: handle in event handler**

```tsx
function Form() {
  const theme = useContext(ThemeContext)

  function handleSubmit() {
    post('/api/register')
    showToast('Registered', theme)
  }

  return <button onClick={handleSubmit}>Submit</button>
}
```

### 5. Chains of Effects

**Incorrect: effect chain to compute final value**

```tsx
function Game() {
  const [card, setCard] = useState(null)
  const [goldCardCount, setGoldCardCount] = useState(0)
  const [round, setRound] = useState(1)
  const [isGameOver, setIsGameOver] = useState(false)

  useEffect(() => {
    if (card?.gold) setGoldCardCount(c => c + 1)
  }, [card])

  useEffect(() => {
    if (goldCardCount > 3) setRound(r => r + 1)
  }, [goldCardCount])

  useEffect(() => {
    if (round > 5) setIsGameOver(true)
  }, [round])
}
```

**Correct: calculate in event handler**

```tsx
function Game() {
  const [card, setCard] = useState(null)
  const [goldCardCount, setGoldCardCount] = useState(0)
  const [round, setRound] = useState(1)
  const [isGameOver, setIsGameOver] = useState(false)

  function handleCardPick(nextCard: Card) {
    const nextGoldCount = nextCard.gold ? goldCardCount + 1 : goldCardCount
    const nextRound = nextGoldCount > 3 ? round + 1 : round
    const nextIsGameOver = nextRound > 5

    setCard(nextCard)
    setGoldCardCount(nextGoldCount)
    setRound(nextRound)
    setIsGameOver(nextIsGameOver)
  }
}
```

### 6. Notifying Parent via Effect

**Incorrect: effect calls parent onChange**

```tsx
function Toggle({ onChange }: { onChange: (isOn: boolean) => void }) {
  const [isOn, setIsOn] = useState(false)

  useEffect(() => {
    onChange(isOn)
  }, [isOn, onChange])

  return <button onClick={() => setIsOn(!isOn)}>Toggle</button>
}
```

**Correct: notify in event handler**

```tsx
function Toggle({ onChange }: { onChange: (isOn: boolean) => void }) {
  const [isOn, setIsOn] = useState(false)

  function handleClick() {
    const nextIsOn = !isOn
    setIsOn(nextIsOn)
    onChange(nextIsOn)
  }

  return <button onClick={handleClick}>Toggle</button>
}
```

### 7. Passing Data Up to Parent

**Incorrect: child fetches, parent uses effect to receive**

```tsx
function Parent() {
  const [data, setData] = useState(null)
  return <Child onFetched={setData} />
}

function Child({ onFetched }: Props) {
  const data = useSomeAPI()
  useEffect(() => {
    if (data) onFetched(data)
  }, [data, onFetched])
}
```

**Correct: parent fetches, passes down**

```tsx
function Parent() {
  const data = useSomeAPI()
  return <Child data={data} />
}
```

### 8. Fetching Without Cleanup (Race Condition)

**Incorrect: no cleanup, stale responses overwrite fresh**

```tsx
function SearchResults({ query }: { query: string }) {
  const [results, setResults] = useState([])

  useEffect(() => {
    fetchResults(query).then(setResults)
  }, [query])
}
```

**Correct: cleanup flag prevents stale updates**

```tsx
function SearchResults({ query }: { query: string }) {
  const [results, setResults] = useState([])

  useEffect(() => {
    let ignore = false
    fetchResults(query).then(data => {
      if (!ignore) setResults(data)
    })
    return () => { ignore = true }
  }, [query])
}
```

### 9. App Initialization in Effect

**Incorrect: runs twice in dev, re-runs on remount**

```tsx
function App() {
  useEffect(() => {
    loadFromStorage()
    checkAuthToken()
  }, [])
}
```

**Correct: module-level guard**

```tsx
let didInit = false

function App() {
  useEffect(() => {
    if (didInit) return
    didInit = true
    loadFromStorage()
    checkAuthToken()
  }, [])
}
```

Reference: [https://react.dev/learn/you-might-not-need-an-effect](https://react.dev/learn/you-might-not-need-an-effect)
