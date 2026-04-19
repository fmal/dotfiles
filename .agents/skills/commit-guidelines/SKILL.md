---
name: commit-guidelines
description: Guidelines for creating git commits. Use when making commits, staging changes for commit, or deciding how to split changes across commits.
user-invocable: false
---

# Commit Guidelines

## Principles

- Each commit should represent a complete, working change
- Commit messages must use conventional commits format
- Write summaries in the imperative mood (`add`, not `added`/`adds`)
- Keep the summary under 72 characters
- Explain what and why, not how

## Conventional Commits

Format: `<type>: <summary>`

Types:

| Type       | Purpose                                 |
| ---------- | --------------------------------------- |
| `feat`     | New feature                             |
| `fix`      | Bug fix                                 |
| `chore`    | Maintenance tasks, dependencies, config |
| `refactor` | Refactoring (no behavior change)        |
| `perf`     | Performance improvement                 |
| `docs`     | Documentation only                      |
| `test`     | Test additions or corrections           |
| `style`    | Code formatting (no logic change)       |

## Body

Skip the body when the subject is self-explanatory. Add a body only for:

- Non-obvious reasoning (the _why_)
- Breaking changes
- Migration notes
- Linked issues or PRs

Wrap body text at 72 characters.

## Breaking Changes

Append `!` after the type and add a `BREAKING CHANGE:` footer:

```
feat!: remove deprecated v1 endpoints

BREAKING CHANGE: v1 endpoints no longer available
```

## Issue References

Reference GitHub issues in the commit footer:

- `Fixes #123` — closes the issue when merged
- `Refs #123` — links without closing

## Examples

```
feat: add OAuth2 login flow
```

```
fix: handle null response in user endpoint

The API could return null for deleted accounts, causing a crash.

Fixes #42
```

```
refactor: extract validation logic to shared module
```
