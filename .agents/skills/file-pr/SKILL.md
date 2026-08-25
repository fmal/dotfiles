---
name: file-pr
description: File a concise pull request. Use when the user asks to file, open, or create a PR for the current branch.
---

# File PR

Before filing, check whether a PR for this branch already exists. Review the
diff locally against the repository's default branch to make sure its contents
match the goal.

PR titles usually become commit messages, so follow the repository's title
conventions. Look at recently merged PRs and Git history for examples. Prefer a
concise, human-readable title that explains why the change matters:

BAD

> ❌ fix(auth): wrap token refresh in a distributed lock

GOOD

> ✅ fix(auth): stop users getting randomly logged out mid-session

Open the description with a simple explanation of the problem based on the
user's original prompt, then briefly explain the solution. Do not lead with an
implementation inventory:

BAD

> ❌ Switched the CSV exporter to stream rows through a cursor with a 500-row
> buffer instead of materializing the full result set. Moved serialization into
> the worker pool, added backpressure handling to the download endpoint, and
> deleted buildFullResultSet and the materializeExport helper.

GOOD

> ✅ Exporting more than ~50k rows crashed the server with an out-of-memory
> error, so our biggest customers couldn't download their data at all. Exports
> now stream, so any size works.

Open a real PR rather than a draft so review bots run.
