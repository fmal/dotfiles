---
name: file-pr
description: File a concise pull request. Use when the user asks to file, open, or create a PR for the current branch.
---

# File PR

Before filing, check whether a PR for this branch already exists. Review the
diff locally against the repository's default branch to make sure its contents
match the goal. Run the `code-simplifier` skill over the diff and commit what
it changes before filing.

PR titles usually become commit messages, so follow the repository's title
conventions. Look at recently merged PRs and Git history for examples. Prefer a
concise, human-readable title that explains why the change matters:

BAD

> ❌ fix(auth): wrap token refresh in a distributed lock

GOOD

> ✅ fix(auth): keep users signed in during a token refresh

Open the description with a simple explanation of the problem based on the
user's original prompt, then briefly explain the solution. Do not lead with an
implementation inventory:

BAD

> ❌ Switched the CSV exporter to stream rows through a cursor with a 500-row
> buffer instead of materializing the full result set. Moved serialization into
> the worker pool, added backpressure handling to the download endpoint, and
> deleted buildFullResultSet and the materializeExport helper.

GOOD

> ✅ Exports of more than 50,000 rows crashed the server with an out-of-memory
> error. Our biggest customers couldn't download their data. The exporter now
> streams rows and no longer builds the whole file in memory, so an export of
> any size completes.

Write the title and body with the `technical-writing` skill, then apply the
`unslop` skill to both. The conventional-commit prefix is convention, not
prose, so neither skill applies to it. In `unslop` that means rules 14 (colon
overuse) and 33 (over-compression). The rest of the title follows both skills,
and the repository's title conventions win where they conflict with either.

Rebase onto the latest default branch before opening. A stale branch wastes a
review round on conflicts. Open a real PR rather than a draft so review bots
run.
