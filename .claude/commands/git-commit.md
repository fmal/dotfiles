---
description: Analyze git changes and create a well-structured commit
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git log:*), Bash(git diff:*)
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Task

Analyze the git changes and create a single, well-crafted commit. If there are unstaged changes that should be committed, stage them first.

## Output rules

- Follow conventional commits format.
- Use the context of the conversation to help derive the message.
- If possible, commit message should state why the change was made not what the change is.
