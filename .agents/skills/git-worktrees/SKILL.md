---
name: git-worktrees
description: Use when creating or removing git worktrees.
---

# Git worktrees

Use `git gtr` for worktrees: on top of `git worktree`, it applies the repo's `.gtrconfig`, which copies env files and runs install hooks. Flags: `git gtr help <command>`.

- Create with `git gtr new <branch> --porcelain` and work in the returned `path`. It branches from the fetched default branch, not HEAD; for a variant of the current branch, add `--from-current --no-fetch`.
- A non-zero exit can leave the worktree behind; report the path stderr names.
- If `hook_status` is `skipped-untrusted` or `partial`, setup did not run: ask the user to review `.gtrconfig` and run `git gtr trust`.
- Remove with `git gtr rm <branch>` when asked, then `git branch -d <branch>`; if git refuses, keep the branch and say so. Use `--force`, `--delete-branch` or `git gtr clean` only on request.
