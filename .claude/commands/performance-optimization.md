---
description: Analyze code for performance bottlenecks and optimization opportunities
argument-hint: <file_or_directory_path>
---

Analyze the code at `$ARGUMENTS` for performance bottlenecks and optimization opportunities.

## Analysis Steps

1. **Understand the scope**
   - If a directory is provided, identify critical files (entry points, hot paths, frequently called utilities)
   - If a file is provided, analyze it in depth along with its dependencies

2. **Identify performance issues** - Look for:

   ### Algorithmic Issues
   - O(n^2) or worse complexity where O(n) or O(n log n) is possible
   - Unnecessary nested loops
   - Missing early returns or short-circuits
   - Repeated calculations that could be cached

   ### Memory Issues
   - Memory leaks (unclosed resources, growing arrays/objects, event listeners)
   - Unnecessary object creation in hot paths
   - Large data structures that could be streamed

   ### I/O & Async Issues
   - Sequential operations that could be parallelized
   - Missing caching for expensive operations
   - N+1 query patterns
   - Missing request batching or debouncing

   ### React/UI Issues
   - Unnecessary re-renders (missing memoization, unstable references)
   - Heavy computation blocking the main thread
   - Missing virtualization for large lists
   - Expensive operations in render path

3. **Assess impact**
   - Estimate relative performance impact (high/medium/low)
   - Consider frequency of execution (hot path vs. cold path)

## Output Format

### Summary
Brief overview of the most critical issues found.

### Critical Issues (High Impact)
| Location | Issue | Recommendation |
|----------|-------|----------------|
| file:line | Description | Fix suggestion |

### Medium Priority Issues
| Location | Issue | Recommendation |
|----------|-------|----------------|
| file:line | Description | Fix suggestion |

### Low Priority / Micro-optimizations
Brief list of minor improvements (only if relevant).

### Questions
Any clarifying questions about usage patterns or constraints that would affect recommendations.
