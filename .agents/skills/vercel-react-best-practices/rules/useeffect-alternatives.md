---
title: Better Alternatives to useEffect
impact: MEDIUM
impactDescription: eliminates unnecessary effects and render passes
tags: useeffect, hooks, derived-state, alternatives
---

## Better Alternatives to useEffect

### Quick Reference

| Situation | DON'T | DO |
|-----------|-------|-----|
| Derived state from props/state | `useState` + `useEffect` | Calculate during render |
| Expensive calculations | `useEffect` to cache | `useMemo` |
| Reset state on prop change | `useEffect` with `setState` | `key` prop |
| User event responses | `useEffect` watching state | Event handler directly |
| Notify parent of changes | `useEffect` calling `onChange` | Call in event handler |
| Fetch data | `useEffect` without cleanup | `useEffect` with cleanup OR framework |

### When You DO Need Effects

- Synchronizing with external systems (non-React widgets, browser APIs)
- Subscriptions to external stores (use `useSyncExternalStore` when possible)
- Analytics/logging that runs because component displayed
- Data fetching with proper cleanup (or use framework's built-in mechanism)

### When You DON'T Need Effects

1. Transforming data for rendering
2. Handling user events
3. Deriving state
4. Chaining state updates

### Decision Tree

```
Need to respond to something?
├── User interaction (click, submit, drag)?
│   → Use EVENT HANDLER
├── Component appeared on screen?
│   → Use EFFECT (external sync, analytics)
├── Props/state changed and need derived value?
│   → CALCULATE DURING RENDER
│       → Expensive? Use useMemo
└── Need to reset state when prop changes?
    → Use KEY PROP on component
```

### 1. Calculate During Render (Derived State)

**Incorrect:**

```tsx
const [fullName, setFullName] = useState('')
useEffect(() => {
  setFullName(firstName + ' ' + lastName)
}, [firstName, lastName])
```

**Correct:**

```tsx
const fullName = firstName + ' ' + lastName
```

### 2. useMemo for Expensive Calculations

**Incorrect:**

```tsx
const [filtered, setFiltered] = useState(items)
useEffect(() => {
  setFiltered(items.filter(expensivePredicate))
}, [items])
```

**Correct:**

```tsx
const filtered = useMemo(
  () => items.filter(expensivePredicate),
  [items]
)
```

### 3. Key Prop to Reset State

**Incorrect:**

```tsx
useEffect(() => {
  resetForm()
}, [userId])
```

**Correct:**

```tsx
<UserForm key={userId} userId={userId} />
```

### 4. Store ID Instead of Object

**Incorrect:**

```tsx
const [selectedItem, setSelectedItem] = useState<Item | null>(null)
useEffect(() => {
  // re-find item when list updates to keep reference fresh
  setSelectedItem(items.find(i => i.id === selectedItem?.id) ?? null)
}, [items])
```

**Correct:**

```tsx
const [selectedId, setSelectedId] = useState<string | null>(null)
const selectedItem = items.find(i => i.id === selectedId) ?? null
```

### 5. Event Handlers for User Actions

**Incorrect:**

```tsx
const [submitted, setSubmitted] = useState(false)
useEffect(() => {
  if (submitted) sendForm(data)
}, [submitted])
```

**Correct:**

```tsx
function handleSubmit() {
  sendForm(data)
}
```

### 6. useSyncExternalStore for External Stores

**Incorrect:**

```tsx
const [isOnline, setIsOnline] = useState(true)
useEffect(() => {
  const handler = () => setIsOnline(navigator.onLine)
  window.addEventListener('online', handler)
  window.addEventListener('offline', handler)
  return () => {
    window.removeEventListener('online', handler)
    window.removeEventListener('offline', handler)
  }
}, [])
```

**Correct:**

```tsx
const isOnline = useSyncExternalStore(
  (callback) => {
    window.addEventListener('online', callback)
    window.addEventListener('offline', callback)
    return () => {
      window.removeEventListener('online', callback)
      window.removeEventListener('offline', callback)
    }
  },
  () => navigator.onLine,
  () => true // server snapshot
)
```

### 7. Lifting State Up

**Incorrect: child fetches, notifies parent via effect**

```tsx
function Child({ onData }: { onData: (d: Data) => void }) {
  const data = useQuery('key')
  useEffect(() => {
    if (data) onData(data)
  }, [data, onData])
}
```

**Correct: parent owns the data**

```tsx
function Parent() {
  const data = useQuery('key')
  return <Child data={data} />
}
```

### 8. Custom Hooks for Data Fetching

**Incorrect: raw useEffect fetch**

```tsx
useEffect(() => {
  fetch(url).then(r => r.json()).then(setData)
}, [url])
```

**Correct: custom hook with cleanup**

```tsx
function useData(url: string) {
  const [data, setData] = useState(null)

  useEffect(() => {
    let ignore = false
    fetch(url)
      .then(r => r.json())
      .then(d => { if (!ignore) setData(d) })
    return () => { ignore = true }
  }, [url])

  return data
}
```

Or better: use your framework's data fetching mechanism (SWR, React Query, etc.).

Reference: [https://react.dev/learn/you-might-not-need-an-effect](https://react.dev/learn/you-might-not-need-an-effect)
