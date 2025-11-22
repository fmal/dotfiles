---
description: Process and address PR review comments from the current pull request
allowed-tools: Bash(gh:*), Bash(git:*), Read, Edit, Write, Grep, Glob, TodoWrite
---

# PR Review Processor

Process and address PR review comments from the current pull request.

## Context

- Repository: !`gh repo view --json nameWithOwner -q .nameWithOwner`
- PR Number: !`gh pr view --json number -q .number 2>/dev/null || echo "No PR found"`

## Steps

1. **ABORT if PR Number above shows "No PR found"** - Tell user to checkout a PR branch first.

2. Fetch all comments:

Get PR-level and review comments:

```bash
gh pr view --comments
```

Then get inline review comments with file context:

```bash
gh api repos/$REPO/pulls/$PR_NUMBER/comments --paginate | jq '[.[] | select(.position | type == "number") | {user: .user.login, user_type: .user.type, path, side, start_side, line, start_line, original_line, original_start_line, position, original_position, diff_hunk, body}]'
```

3. After reading all comments, I will:

- Analyze each comment to understand what needs to be done
- Identify specific lines/sections that need modification based on line numbers, diff hunks, and file paths
- Group related comments by file or topic
- Identify which comments are:
  - ✅ Actionable code changes
  - ❓ Questions that need answers
  - 💬 Suggestions to consider
  - ⛔ Issues that need to be fixed
- Ask you for clarification on any ambiguous feedback

4. Create a task list using TodoWrite of all changes needed and ask for your approval before proceeding

5. Once approved, I'll work through each task:

- Mark the current task as in_progress
- Locate and read the relevant code
- Make the necessary changes
- Mark the task as completed
- Create focused commits for logical groups of changes (not necessarily one commit per task)

6. After all changes are complete:

- Ask if you want to run tests (and what command to use if not obvious from the project)
- Show a summary of all changes made
- Ask for approval before pushing

7. Finally:

- Push the changes to the PR branch
- Generate a summary comment for the PR that lists:
  - Each review comment addressed with brief explanation
  - Any questions that need discussion
- Post the summary using:

```bash
gh pr comment --body "<summary text>"
```

- Ask if you want to request re-review:

```bash
gh pr review --approve  # or just view to see review status
```

## Usage

Just run `/prp` when you have a PR with review comments. I'll guide you through addressing each piece of feedback systematically.

## Example Workflow

```
You: /prp
Claude: [Checks PR exists, fetches and displays all comments]
Claude: I've identified 5 actionable items and 2 questions. Creating task list...
Claude: [Shows task list] Should I proceed with these changes?
You: Yes
Claude: [Makes changes one by one, showing progress with todos]
Claude: All changes complete! Want me to run tests?
You: Yes
Claude: [Runs tests and shows results]
Claude: Tests pass! Ready to push?
You: Yes
Claude: [Pushes changes]
Claude: Here's a summary comment I'll post to the PR: [shows summary]
You: Looks good
Claude: [Posts comment] Done! Request re-review?
```
