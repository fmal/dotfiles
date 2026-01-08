---
description: Simplify code for clarity, consistency, and maintainability while preserving functionality
argument-hint: <file_path_or_description_of_recent_changes>
---

Simplify the code at `$ARGUMENTS` for clarity, consistency, and maintainability while preserving all functionality.

Apply expert code simplification techniques. Prioritize readable, explicit code over overly compact solutions while following project-specific best practices.

## Core Principles

1. **Preserve Functionality**: Never change what the code does - only how it does it. All original features, outputs, and behaviors must remain intact.

2. **Apply Project Standards**: Follow project coding standards and match existing patterns.

3. **Enhance Clarity**: Simplify code structure by:

   - Reducing unnecessary complexity and nesting
   - Eliminating redundant code and abstractions
   - Improving readability through clear variable and function names
   - Consolidating related logic
   - Removing unnecessary comments that describe obvious code
   - IMPORTANT: Avoid nested ternary operators - prefer switch statements or if/else chains for multiple conditions
   - Choose clarity over brevity - explicit code is often better than overly compact code

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

## Output Format

### Summary

Brief overview of the simplifications made.

### Changes Made

| Location  | Before      | After       | Rationale                  |
| --------- | ----------- | ----------- | -------------------------- |
| file:line | Description | Description | Why this improves the code |

### Questions

Any clarifying questions about the code or constraints that would affect recommendations.
