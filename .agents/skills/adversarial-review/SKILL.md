---
name: adversarial-review
description: Rigorous critique-fix loop using fresh-eyes reviewer subagents. Use when the user asks for an "adversarial review", says "review my changes rigorously", "critique this code" or invokes `/adversarial-review`. Expensive — don't trigger on casual review requests.
argument-hint: "[files/dirs] [--pr]"
---

# Adversarial Review

Automated critique-fix loop using fresh-eyes reviewer subagents. Each round, a new subagent reviews the code cold — no knowledge of why decisions were made, no attachment to the implementation. The main agent fixes Critical and Suggestion findings, then a fresh reviewer checks again. Loop stops when only Nitpicks remain or after 3 rounds.

## When to Use

- After implementation, before committing — especially for features and refactors
- When changes touch critical paths, security-sensitive code, or complex logic
- When you want a review that's harder than what you'd give yourself

## When NOT to Use

- Trivial changes, docs-only, config tweaks
- Mid-implementation — finish building first, then review
- When a quick sanity check is enough

## Input Modes

Parse `$ARGUMENTS` to determine what to review:

- **No args:** review uncommitted changes — run `git diff` and `git diff --cached`
- **File/dir paths:** review specific files — read them directly
- **`--pr` flag:** review the full branch diff — `git diff main...HEAD` (try `master` if `main` doesn't exist)

If the diff is empty, tell the user there's nothing to review and stop.

## Step 1: Gather Context

Collect two things before dispatching the reviewer.

**The diff.** Based on the input mode above.

**Project conventions.** Search the project for convention docs the reviewer should know about:

- CLAUDE.md files (project root and nested)
- Lint/style configs (`.eslintrc.*`, `.prettierrc`, etc.)
- Convention docs in common locations (`docs/`, `.cursor/rules/`, `AGENTS.md`)

**Budget:** Keep convention context to ~5K tokens. Prioritize CLAUDE.md and lint configs. Skip feature docs and READMEs — the reviewer is judging code quality, not feature completeness.

## Step 2: Dispatch Reviewer Subagent

Use the **Agent tool** with `subagent_type: general-purpose` and the prompt below, substituting `{conventions}` and `{diff}`.

### Reviewer Prompt

```
You are a senior developer doing a cold code review. You have never seen this
code before. You have no context on why decisions were made. You did not write
any of this. Review with completely fresh eyes.

## Project Conventions

{conventions}

## Code to Review

{diff}

## Review Criteria

Be opinionated. Review for:

- **Correctness:** bugs, logic errors, edge cases, race conditions
- **Security:** injection, auth bypass, data exposure, OWASP top 10
- **DRY:** duplicated logic that should be extracted
- **Modularity:** classes/methods doing too much, unclear boundaries
- **Testability:** code that's hard to test, missing test coverage
- **Simplicity:** over-engineering, unnecessary abstractions, premature generalization
- **Architecture:** does it conform to the project's established patterns?
- **Naming:** unclear or misleading names
- **Error handling:** swallowed errors, missing edge cases

## Output Format

Return findings as a list. Each finding MUST have:

- **Severity:** Critical | Suggestion | Nitpick
- **Location:** file path and line range
- **Issue:** what's wrong
- **Fix:** specific, concrete recommendation

Severity definitions:
- **Critical** = bugs, security issues, data loss risk, broken functionality
- **Suggestion** = meaningful improvements to quality, maintainability, or conformance
- **Nitpick** = style preferences, minor naming quibbles, cosmetic issues

Be honest about severity. Don't inflate Nitpicks to Suggestions.
If the code is solid, say so — an empty findings list is a valid result.
```

## Step 3: Process Findings

1. **Fix** all Critical and Suggestion items directly in the code
2. **Skip** any finding that conflicts with project conventions or prior discussion — note why
3. **Log** Nitpicks without acting on them
4. Track what was found and fixed this round

The reviewer has fresh eyes but lacks your conversation context. Use judgment — if a finding is wrong or would break something, skip it and note why.

## Step 4: Loop

After applying fixes:

1. Collect the new diff against the **original baseline** (not the previous round). The reviewer should see the full changeset each time.
2. Spawn a **fresh** reviewer subagent. Do not reuse the previous one.
3. Stop when either:
   - **Only Nitpicks remain** → code is clean
   - **3 rounds completed** → report any remaining non-nitpick findings

## Step 5: Report

```
## Adversarial Review Complete

**Rounds:** N of 3
**Result:** [Clean — only nitpicks remain | Capped — N issues remain after 3 rounds]

### Round 1
- [Critical] file.ts:12-15 — description (FIXED)
- [Suggestion] file.ts:30 — description (FIXED)
- [Nitpick] file.ts:45 — description

### Round 2
- [Nitpick] file.ts:32 — description

### Remaining Nitpicks
- file.ts:45 — description
- file.ts:32 — description
```

If the first round returns no findings, report that the code passed clean and stop.

## Common Mistakes

- **Reusing the same subagent** for round 2 — it remembers its own findings and loses fresh eyes. Always spawn a new one.
- **Diffing fixes only** — the round 2 reviewer should see the full changeset, not just what changed since round 1.
- **Applying every finding blindly** — you have conversation context the reviewer lacks. Skip findings that conflict with conventions or prior decisions, and note why.
- **Running this on trivial changes** — this is expensive.
