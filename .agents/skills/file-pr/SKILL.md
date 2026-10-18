---
name: file-pr
description: Use when the user asks to file, open, or create a PR for the current branch.
---

# File PR

Rebase onto the latest default branch. A stale branch wastes a review round on
conflicts. Review the diff locally against the repository's default branch to
make sure its contents match the goal. If the diff changes code, run the
`code-simplifier` skill over it and commit what it changes before filing.

PR titles usually become commit messages, so follow the repository's title
conventions. Look at recently merged PRs and Git history for examples. Prefer a
concise, human-readable title that explains why the change matters:

BAD

> ❌ fix(auth): wrap token refresh in a distributed lock

GOOD

> ✅ fix(auth): keep users signed in during a token refresh

Use this body template. If the repository has its own PR template, fold these
parts into its sections instead.

```markdown
<problem, then solution>

## Evidence

<before and after>

## Risk

**Door:** <one-way or two-way>
**Blast radius:** <what the change can break>
```

Open with a simple explanation of the problem, taken from the user's original
prompt or the issue the branch addresses, then briefly explain the solution.
Do not lead with an implementation inventory:

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

Evidence is concrete proof that the change works, from runs in this session:
the test or command that failed before and passes now. If the session has no
before run, get one from the default branch. For visual changes, use before
and after screenshots from `playwright-cli screenshot --filename`, or short
videos from `playwright-cli video-start` when they fit better, saved outside
the repository. Reference each in the section as
`![before](/tmp/pr/before.png)` and pass the same path to `--attach` on
`gh pr create` or `gh pr edit`. Put a video reference alone in its paragraph
so it renders as a player. Drop the Evidence section when there is nothing to
show.

Say whether the merge is a one-way or two-way door, meaning how cheap it is
to roll back. For a one-way door, name the reason, such as a destructive
migration. Name the blast radius in a few words: which consumers, surfaces,
or data the change can break.

Write the title and body with the `technical-writing` skill, which applies
`unslop`. The conventional-commit prefix is convention, not prose, so neither
skill applies to it. In `unslop` that means rules 14 (colon overuse) and 33
(over-compression). The rest of the title follows both skills, and the
repository's title conventions win where they conflict with either.

Push the branch, with `--force-with-lease` if it was pushed before the rebase.
If a PR for this branch already exists, update its title and body with
`gh pr edit`. Otherwise open a real PR rather than a draft so review bots run.
