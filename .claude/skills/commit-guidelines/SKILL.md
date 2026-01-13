---
name: commit-guidelines
description: Guidelines for creating git commits. Use when making commits, staging changes for commit, or deciding how to split changes across commits.
user-invocable: false
---

# Commit Guidelines

## Principles

- Each commit should represent a complete, working change
- Commit messages must use conventional commits format
- Keep the summary under 72 characters
- Explain what and why, not how

## Conventional Commits

Format: `<type>: <summary>`

Types:

- `feat:` - new feature
- `fix:` - bug fix
- `chore:` - maintenance, dependencies, config
- `docs:` - documentation only
- `refactor:` - code change that neither fixes a bug nor adds a feature
- `test:` - adding or updating tests
- `style:` - formatting, whitespace (no code change)
