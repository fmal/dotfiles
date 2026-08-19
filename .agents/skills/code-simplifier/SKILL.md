---
name: code-simplifier
description: Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Use when asked to "simplify code", "clean up code", "refactor for clarity", "improve readability", "deslop", or review recently modified code for elegance. Focuses on project-specific best practices.
argument-hint: <file_path_or_description_of_recent_changes>
---

# Code Simplifier

Apply expert code simplification techniques. Prioritize readable, explicit code over overly compact solutions while following project-specific best practices.

Simplify the code at `$ARGUMENTS`. If no target is specified, identify and simplify code that has been recently modified or touched in the current session.

## Core Principles

1. **Preserve Functionality**: Never change what the code does - only how it does it. All original features, outputs, and behaviors must remain intact.

2. **Apply Project Standards**: Follow project coding standards and match existing patterns.

3. **Enhance Clarity**: Simplify code structure by:
   - Reducing unnecessary complexity and nesting
   - Eliminating redundant code and abstractions
   - Improving readability through variable and function names that say what they hold without a trip to the implementation
   - Consolidating related logic, and merging types, functions, or constants that overlap so the reader holds fewer distinct concepts in their head
   - **Avoiding nested ternary operators** - prefer switch statements or if/else chains for multiple conditions
   - **Removing derivable state** - if a value can be computed from values already in scope, don't pass or store it separately
   - **Removing comments the code already states** - apply the deletion test: if deleting the comment loses no information, delete it. Go after comments that restate the line below them, narrate structure (`// Step 2: validate`, `// --- Helpers ---`), or explain language and library semantics. Keep what code cannot say: why this approach, a non-obvious constraint, a spec or bug link, a footgun warning - and leave docstrings on exported API alone
   - **Removing defensive scaffolding** - drop try/catch, null guards, and fallbacks whose failure case cannot occur on the path they sit on; keep them at genuine trust boundaries (I/O, user input, third-party responses)
   - **Removing casts that only silence the compiler** - if an `any` cast or non-null assertion exists solely to clear a type error, fix the type instead; use `unknown` plus narrowing where the shape is genuinely not known
   - Choosing clarity over brevity - explicit code is often better than overly compact code

4. **Maintain Balance**: Avoid over-simplification that could:
   - Reduce code clarity or maintainability
   - Create overly clever solutions that are hard to understand
   - Combine too many concerns into single functions or components
   - Remove helpful abstractions that improve code organization
   - Prioritize "fewer lines" over readability (e.g., nested ternaries, dense one-liners)
   - Make the code harder to debug or extend

5. **Focus Scope**: Only refine code that has been specified or recently modified, unless explicitly instructed to review a broader scope. Within that scope, prefer minimal, focused edits over broad rewrites.

## Refinement Process

1. Read and understand the specified code
2. Identify opportunities to improve elegance and consistency
3. Apply project-specific best practices and coding standards
4. Ensure all functionality remains unchanged
5. Verify the refined code is simpler and more maintainable

## Examples

### Nested ternaries → early returns

```typescript
// before
const status = isLoading
  ? "loading"
  : hasError
    ? "error"
    : isComplete
      ? "complete"
      : "idle";

// after
function getStatus(isLoading: boolean, hasError: boolean, isComplete: boolean) {
  if (isLoading) return "loading";
  if (hasError) return "error";
  if (isComplete) return "complete";
  return "idle";
}
```

### Overly compact → clear steps

```typescript
// before
const result = arr
  .filter((x) => x > 0)
  .map((x) => x * 2)
  .reduce((a, b) => a + b, 0);

// after
const positiveNumbers = arr.filter((x) => x > 0);
const doubled = positiveNumbers.map((x) => x * 2);
const sum = doubled.reduce((a, b) => a + b, 0);
```

### Redundant abstraction → direct check

```typescript
// before
function isNotEmpty(arr: unknown[]) {
  return arr.length > 0;
}
if (isNotEmpty(items)) { ... }

// after
if (items.length > 0) { ... }
```

### Comments that restate code → delete; comments that add context → keep

```typescript
// before
// Step 1: increment the retry counter
retries++;

// Loop through each user and send them an email
for (const user of users) {
  sendEmail(user);
}

// Convert the total to cents
const amountCents = Math.round(total * 100);

// after
retries++;

for (const user of users) {
  sendEmail(user);
}

// Stripe truncates sub-cent amounts, so bill in integer cents to avoid drift (BILL-412)
const amountCents = Math.round(total * 100);
```

### Placeholder names → names that carry the meaning

```typescript
// before
function proc(d: Subscriber[]) {
  const res = d.filter((s) => s.status === Status.Active);
  const flag = res.length > 0;
  return { res, flag };
}

// after
function findActiveSubscribers(subscribers: Subscriber[]) {
  const active = subscribers.filter((s) => s.status === Status.Active);
  const hasActive = active.length > 0;
  return { active, hasActive };
}
```

### Defensive scaffolding → trust the internal path

```typescript
// before
function totalPrice(items: Item[]) {
  try {
    if (!items || !Array.isArray(items)) return 0;
    return items.reduce((sum, item) => sum + (item?.price ?? 0), 0);
  } catch {
    return 0;
  }
}

// after
function totalPrice(items: Item[]) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

### Cast to silence the compiler → fix the type

```typescript
// before
const config = JSON.parse(raw) as any;
doSomething(config.timeout);

// after
const config: unknown = JSON.parse(raw);
if (!isConfig(config)) throw new Error("malformed config");
doSomething(config.timeout);
```

### Derivable state → compute where needed

```typescript
// before
function render(content: string, baseline: string, isDirty: boolean) {
  return isDirty ? `${content} *` : content;
}
render(content, baseline, content !== baseline);

// after
function render(content: string, baseline: string) {
  const isDirty = content !== baseline;
  return isDirty ? `${content} *` : content;
}
render(content, baseline);
```
