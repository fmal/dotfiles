---
name: ts-best-practices
description: TypeScript type-safety rules. Use when reading or editing any .ts or .tsx file.
---

# Type Safety

This project's TypeScript policy. Apply when writing or reviewing TypeScript.

| Rule | Summary |
|------|---------|
| Validated assertions | Validate at boundaries; reserve `as` for fully checked data. Prefer Zod/Valibot over manual validation. |
| `unknown` over `any` | `any` disables type checking for everything it touches. External data is always `unknown`. |
| Discriminated unions | Model variants with a shared literal discriminant. No optional-field bags. |
| Branded types | Brand primitives with `& { readonly __brand: "X" }` so they can't be mixed up. Validate once at creation. A brand comes from a verifying type guard (`input is TaskId`), never from `as`. |
| Constructive modeling | Build the shape so the illegal value can't be constructed: `[T, ...T[]]` for non-empty, `[T, T][]` for even length, `start` plus `duration` for a range. |
| Simplest total type | Keep `T[]` while every operation on it stays total. Strengthen to `NonEmpty<T>` only where the loose type forces `!`, a cast, or a "should never happen" throw. |
| Schema-derived types | Reach for `Pick`/`Omit`/`Parameters`/`ReturnType`/`Awaited`/`typeof` (and generated schema types) before declaring a new interface. |
| Narrowing hierarchy | Prefer: discriminated union switch > `in` operator > typeof/instanceof > type guard > `as` |
| Type guards | Must actually verify the claim. Name them `isX` or `hasX`. Prefer discriminant narrowing when possible. |
| Local narrowing | Narrow a nullable where it is used. A `!` that leans on a check elsewhere breaks silently when that check moves. |
| Exhaustiveness checks | Inline `const _exhaustive: never = x;` in default arms so the compiler errors when a new variant is added. |
| `satisfies` over `as` | Use `satisfies` to check compatibility without replacing the inferred type. Use `as const` when literal or readonly inference is needed. |
| Readonly array params | Type array params the function doesn't mutate as `readonly T[]`. It accepts mutable and readonly arrays alike, and the compiler holds the no-mutation promise. |
| Impossible states | If a bug requires asking "can this combination happen?" the type is too loose. Tighten it. |
| Omit return types | Don't annotate return types unless they add value (e.g. public API, recursive functions, overloads). Let inference do the work. |
| Object args | Use an object parameter when arguments could be swapped unnoticed: two or more of the same type, booleans, or several optionals. Keep positional args for single or distinctly typed params and on hot paths. |

Read [references/patterns.md](references/patterns.md) for code examples of each rule.
