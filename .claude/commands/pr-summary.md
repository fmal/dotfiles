---
description: Generate a concise PR description by analyzing branch changes
allowed-tools: Bash(git:*)
model: haiku
---

## Context

- Current branch: !`git branch --show-current`
- Base branch: !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`

## Tasks

1. Using the base branch above (call it <BASE_BRANCH>), run in parallel:

   - `git log --no-merges --first-parent --oneline <BASE_BRANCH>..`
   - `git diff -M -C --no-color <BASE_BRANCH>..`

2. Analyze the provided branch commits and diff of changes to infer the overall intent, purpose, and impact of the changes. Then, generate a clear, reviewer-friendly PR description that explains _why_ the changes were made, what problem they solve, and any key impacts (e.g., on users, performance, or architecture). Focus on high-level insights to help reviewers quickly understand the value without diving into code details.

## Reasoning steps (think step-by-step before outputting)

1. Review commits: Group them thematically (e.g., bug fixes, features, refactors) and identify patterns or overarching goals.
2. Examine diff: Summarize major additions/removals/modifications, ignoring minor formatting or test-related changes.
3. Infer intent: Combine insights from commits and diff to deduce the "why" (e.g., "Fixes performance bottleneck in API calls" vs. just listing code changes).
4. Check for edge cases:

- If no changes vs. <BASE_BRANCH> detected, output: “No changes found between branches.”

## Output rules

- Keep it under three paragraphs. The shorter, the better.
- Use simple, direct language. Avoid hype, jargon, or fluff.
- Do not include test changes or mention tests.
- Avoid obvious implementation details already clear from the code.
- Structure with markdown to annotate important parts.
- Wrap the final output in a markdown code block (```markdown) to preserve literal markdown syntax for copy-pasting.
