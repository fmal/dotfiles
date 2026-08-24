---
name: ts-best-practices
description: >
  TypeScript type safety guidelines for writing maximally type-safe code. Use when reading or editing any .ts or .tsx file.
---

# Type Safety

This project's TypeScript policy. Apply when writing or reviewing TypeScript.

| Rule | Summary |
|------|---------|
| No `as` casts | Every `as` is a potential runtime crash. Validate at boundaries, then cast only if earned. Prefer Zod/Valibot over manual validation. |
| `unknown` over `any` | `any` disables type checking for everything it touches. External data is always `unknown`. |
| Discriminated unions | Model variants with a shared literal discriminant. No optional-field bags. |
| Branded types | Brand primitives with `& { readonly __brand: "X" }` so they can't be mixed up. Validate once at creation. |
| Constructive modeling | Build the shape so the illegal value can't be constructed: `[T, ...T[]]` for non-empty, `[T, T][]` for even length, `start` plus `duration` for a range. |
| Simplest total type | Keep `T[]` while every operation on it stays total. Strengthen to `NonEmpty<T>` only where the loose type forces `!`, a cast, or a "should never happen" throw. |
| Schema-derived types | Reach for `Pick`/`Omit`/`Parameters`/`ReturnType`/`Awaited`/`typeof` (and generated schema types) before declaring a new interface. |
| Narrowing hierarchy | Prefer: discriminated union switch > `in` operator > typeof/instanceof > type guard > `as` |
| Type guards | Must actually verify the claim. Name them `isX` or `hasX`. Prefer discriminant narrowing when possible. |
| Exhaustiveness checks | Inline `const _exhaustive: never = x;` in default arms so the compiler errors when a new variant is added. |
| `satisfies` over `as` | When verifying a value matches a type without widening, use `satisfies` to preserve literal types. |
| Impossible states | If a bug requires asking "can this combination happen?" the type is too loose. Tighten it. |
| Omit return types | Don't annotate return types unless they add value (e.g. public API, recursive functions, overloads). Let inference do the work. |

Read [references/patterns.md](references/patterns.md) for code examples of each rule.
