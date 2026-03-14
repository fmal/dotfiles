---
name: audit-plan
description: Audit the current plan against the original user request and produce a minimally patched revision.
disable-model-invocation: true
---

# Plan Audit

Audit the current plan for coverage and alignment against the original user request.

## Input

Treat the original user request as the source of truth.

## Instructions

- Identify the major requirements implied or stated in the original user request
- For each major requirement, mark it as `Covered`, `Partial`, or `Missing`
- Cite evidence from the plan using a section name, bullet, or short quote
- If there is no clear evidence, do not assume coverage; mark it `Partial` or `Missing`
- Be strict about evidence and alignment
- Do not give credit for items that are only implied unless the plan clearly addresses them
- Call out ambiguous requirements or risky assumptions explicitly

## Output

### Requirement Audit

Provide a concise list or table with:

- Requirement
- Status: `Covered` / `Partial` / `Missing`
- Evidence from the plan

### Coverage Score

- Give a single score from `0-100`
- Add a 1-2 sentence rationale

### Top Gaps

- List the most important missing items, partial coverage, and risky assumptions
- Prioritize by impact on delivery, correctness, or scope alignment

### Patched Plan

- Produce a revised version of the plan that closes the gaps with minimal changes
- Preserve the original structure, ordering, and wording where possible
- Prefer targeted edits or added bullets over a rewrite
- Keep it concise and implementation-oriented
- Do not expand scope beyond the original request unless needed to close a clear gap
