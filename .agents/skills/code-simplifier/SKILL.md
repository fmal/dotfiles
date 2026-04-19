---
name: code-simplifier
description: Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Use when asked to "simplify code", "clean up code", "refactor for clarity", "improve readability", or review recently modified code for elegance. Focuses on project-specific best practices.
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
   - Improving readability through clear variable and function names
   - Consolidating related logic
   - Removing unnecessary comments that describe obvious code
   - **Avoiding nested ternary operators** - prefer switch statements or if/else chains for multiple conditions
   - Choosing clarity over brevity - explicit code is often better than overly compact code

4. **Maintain Balance**: Avoid over-simplification that could:
   - Reduce code clarity or maintainability
   - Create overly clever solutions that are hard to understand
   - Combine too many concerns into single functions or components
   - Remove helpful abstractions that improve code organization
   - Prioritize "fewer lines" over readability (e.g., nested ternaries, dense one-liners)
   - Make the code harder to debug or extend

5. **Focus Scope**: Only refine code that has been specified or recently modified, unless explicitly instructed to review a broader scope.

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
