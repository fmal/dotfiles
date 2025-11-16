---
description: Analyze and fix a GitHub issue with comprehensive testing and verification
argument-hint: <issue_number>
allowed-tools: Bash(gh *), Read, Edit, Write, Bash(git *)
---

Analyze and fix the GitHub issue: $ARGUMENTS.

Follow these steps:

## Plan

1. Use `gh issue view` to get the issue details
2. Understand the problem described in the issue
3. Ask me for clarification on any questions you might have
4. Search the codebase for relevant files to understand the context
5. Think harder about how to break the issue down into a series of small, manageable tasks
6. Document your plan

   - Include the issue name in the plan filename
   - Include a link to the issue in the plan

7. Before writing any code, ask me to approve the plan

## Create

1. Create a new branch for the issue
2. Solve the issue in small, manageable steps, according to your plan
3. Create a commit for each step
4. After each commit, yield the chat back to me so I can review the code

## Verify

- Run the full test suite to ensure you haven't broken anything
- If the tests are failing, fix them
- Ensure code passes linting and type checking

Remember to use the GitHub CLI (`gh`) for all GitHub-related tasks.
