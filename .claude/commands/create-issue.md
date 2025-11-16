---
description: Create a new GitHub issue from a brief description
argument-hint: <brief description>
allowed-tools: Bash(gh:*), Bash(git:*), Read, Grep, Glob
---

Create a new GitHub issue based on this brief description: $ARGUMENTS

Follow these steps:

1. Analyze the brief description provided
2. Expand it into a proper GitHub issue with:
   - A clear, descriptive title
   - A detailed description explaining:
     - Current behavior/problem
     - Expected behavior/solution
     - Any relevant context or examples
     - Suggested implementation approach (if applicable)
3. Show me a draft and ask for follow-up or notes
4. When confirmed, use `gh issue create` to create the issue with the expanded content
5. Show the created issue number and link
6. Ask if I want to start working on it immediately

Make the issue description helpful and actionable for future development.
