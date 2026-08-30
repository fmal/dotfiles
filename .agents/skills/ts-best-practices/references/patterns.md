# Type Safety Patterns

Code examples for each rule in the project's TypeScript policy.

## Never `as` cast

```ts
// BAD
const user = data as User;

// GOOD — validate at the boundary
function parseUser(data: unknown): User {
  if (typeof data !== "object" || data === null) throw new Error("expected object");
  if (!("id" in data) || typeof (data as Record<string, unknown>).id !== "string")
    throw new Error("expected id");
  // ... validate all fields
  return data as User; // OK — earned cast after full validation
}
```

**Refactoring `as` out of existing code:** Determine *why* TypeScript can't infer the type:
- Missing discriminant field — add one, use discriminated union
- Overly wide type (e.g. `Record<string, any>`) — narrow the type definition
- Untyped API boundary — add a type guard or schema parse at the boundary
- Genuinely impossible to express — use a branded type or `satisfies` instead

## `unknown` over `any`

```ts
// BAD
function handle(input: any) { return input.foo.bar; }

// GOOD
function handle(input: unknown) {
  if (typeof input === "object" && input !== null && "foo" in input) {
    // narrowed — compiler verifies access
  }
}
```

When receiving data from external sources (API responses, JSON parse, event payloads, message passing), always type as `unknown` and narrow.

## Discriminated Unions

```ts
// BAD — optional fields create ambiguous states
type Shape = { kind?: string; radius?: number; width?: number; height?: number };

// GOOD — impossible states are unrepresentable
type Shape =
  | { kind: "circle"; radius: number }
  | { kind: "rect"; width: number; height: number };
```

Rules:
- Discriminant field must be a literal type (string literal, number literal, `true`/`false`)
- Every variant shares the same discriminant field name
- Each variant's discriminant value is unique

## Branded Types

Brand primitives so they can't be mixed up. Validate once at creation; downstream code trusts the type.

```ts
type TaskId = string & { readonly __brand: "TaskId" };
type UserId = string & { readonly __brand: "UserId" };

// Prevents accidentally passing a UserId where a TaskId is expected
function getTask(id: TaskId): Promise<Task> { ... }

function parseTaskId(input: string): TaskId {
  if (!isUUID(input)) throw new Error(`Invalid task id: ${input}`);
  return input as TaskId;
}
```

Match the `readonly __brand: "X"` shape; don't invent a new convention.

## Constructive Modeling

Build the type from parts that are all legal instead of restricting a loose type with runtime checks.

Non-empty, via a variadic tuple:

```ts
type NonEmpty<T> = [T, ...T[]];

// BAD — T[] plus a length check every caller must repeat
function pickWinner(entries: string[]): string {
  if (entries.length === 0) throw new Error("no entries");
  return entries[Math.floor(Math.random() * entries.length)];
}

// GOOD — an empty value of the type can't exist
function pickWinner(entries: NonEmpty<string>): string {
  return entries[Math.floor(Math.random() * entries.length)];
}
```

Where a plain `T[]` arrives, narrow once with a guard. The fact then travels in the type:

```ts
const isNonEmpty = <T>(arr: T[]): arr is NonEmpty<T> => arr.length > 0;
```

Even length, as pairs (TypeScript has no refinement types; you don't need one):

```ts
type Pairs<T> = [T, T][];
```

A time range, as start plus duration:

```ts
// BAD — a comment holds the invariant
type TimeRange = { start: Date; end: Date }; // start <= end

// GOOD — a negative range can't be written; derive end when needed
type TimeRange = { start: Date; durationMs: number };
```

Pick the representation that makes the bad state unconstructable, then expose the reading you need on top (`pairs.flat()`, a `rangeEnd()` helper).

## Simplest Total Type

Don't strengthen everything. Keep `T[]` when every operation on it is total:

```ts
const sum = (xs: number[]) => xs.reduce((a, b) => a + b, 0); // [] is 0, fine
```

Strengthen when the loose type forces a lie at a use site. The tells are `!`, `arr[0] as T`, and a "should never happen" throw:

```ts
// BAD — partiality smuggled past the compiler
function newestSession(sessions: Session[]): Session {
  return sessions.at(0)!;
}

// GOOD — strengthen the input; the assertion disappears
function newestSession(sessions: NonEmpty<Session>): Session {
  return sessions[0];
}
```

Weakening the result to `Session | undefined` is the other total signature. Either way the empty case lands at the call site, the one place that knows what empty means.

## Narrowing Hierarchy

From best to last-resort:

1. **Discriminated union switch / if.** Compiler narrows automatically.
2. **`in` operator.** `"key" in obj` narrows to variants containing that key.
3. **`typeof` / `instanceof`.** For primitives and class instances.
4. **User-defined type guard.** When the above aren't enough.
5. **`as` cast.** Only after validation.

```ts
function area(s: Shape): number {
  if ("radius" in s) return Math.PI * s.radius ** 2; // narrowed to circle
  return s.width * s.height; // narrowed to rect
}
```

## Type Guards

```ts
function isCircle(s: Shape): s is Shape & { kind: "circle" } {
  return s.kind === "circle";
}
```

Rules:
- The guard body must actually verify the claim — a lying guard is worse than `as`
- Prefer discriminated union narrowing over custom guards when possible
- Name guards `isX` or `hasX` for readability

## Exhaustiveness Checks

In default arms, assign the discriminant to a `never`-typed local. The compiler errors if a new variant is added without handling.

```ts
// Value-returning switch
function area(s: Shape): number {
  switch (s.kind) {
    case "circle":
      return Math.PI * s.radius ** 2;
    case "rect":
      return s.width * s.height;
    default: {
      const _exhaustive: never = s;
      return _exhaustive;
    }
  }
}

// Void switch
function handle(s: Shape): void {
  switch (s.kind) {
    case "circle":
      drawCircle(s);
      break;
    case "rect":
      drawRect(s);
      break;
    default: {
      const _exhaustive: never = s;
      void _exhaustive;
    }
  }
}
```

Return-style in value-returning switches; void-style in statement switches.

## `satisfies` Over `as`

```ts
// BAD — widens, loses literal types
const config = { theme: "dark", cols: 3 } as Config;

// GOOD — validates AND preserves literal types
const config = { theme: "dark", cols: 3 } satisfies Config;
// config.theme is "dark" (literal), not string
```

## Making Impossible States Unrepresentable

```ts
// BAD — can be { loading: true, data: User, error: Error } simultaneously
type State = { loading: boolean; data?: User; error?: Error };

// GOOD — exactly one state at a time
type State =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: User }
  | { status: "error"; error: Error };
```

If a bug requires checking "wait, can this combination actually happen?" — the type is too loose. Tighten it so the type system answers that question at compile time.

## Schema-Derived Types

When a `.proto`, OpenAPI spec, GraphQL schema, Zod schema, or database migration already defines a shape, derive from the generated types instead of duplicating them.

```ts
// BAD — duplicate shape, drifts when the schema changes
type CheckSummary = {
  totalCount: number;
  checks: { name: string; status: string }[];
};
function renderChecks(s: CheckSummary) { /* ... */ }

// GOOD — derive from the generated schema type
import type { ChecksMessage } from "<generated module>";
function renderChecks(s: Pick<ChecksMessage, "totalCount" | "checks">) { /* ... */ }
```

Reach for `Pick`, `Omit`, `Parameters`, `ReturnType`, `Awaited`, `typeof` before writing a new interface.

## Omit Return Types

```ts
// BAD — redundant, adds noise
function add(a: number, b: number): number {
  return a + b;
}

// GOOD — inferred correctly
function add(a: number, b: number) {
  return a + b;
}

// OK — return type adds value (public API contract, recursive, overloads)
export function parseConfig(raw: unknown): Config {
  // ...
}
```

Annotate return types when they serve a purpose: exported API boundaries, recursive functions, overloaded signatures, or when inference produces a type that's too wide. Otherwise let TypeScript infer.
