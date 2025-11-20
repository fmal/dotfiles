---
description: Creates an engineering implementation plan based on user requirements and exports it to a filename
argument-hint: USER_PROMPT="<requirements>"
---

# Quick Plan

Create a detailed implementation plan based on the user's requirements provided through the `USER_PROMPT` variable. Analyze the request, think through the implementation approach, and save a comprehensive specification document to `plan_<name-of-plan>.md` that can be used as a blueprint for actual development work.

## Variables

USER_PROMPT: $ARGUMENTS

## Instructions

- Carefully analyze the user's requirements provided in the `USER_PROMPT` variable
- Think deeply about the best approach to implement the requested functionality or solve the problem
- Create a concise implementation plan that includes:
  - Clear problem statement and objectives
  - Technical approach and architecture decisions
  - Step-by-step implementation guide
  - Potential challenges and solutions
  - Testing strategy
  - Success criteria
- Generate a descriptive, kebab-case filename based on the main topic of the plan
- Save the complete implementation plan to `plan_<descriptive-name>.md`
- Ensure the plan is detailed enough that another developer could follow it to implement the solution
- Include code examples or pseudo-code where appropriate to clarify complex concepts
- Consider edge cases, error handling, and scalability concerns
- Structure the document with clear sections and proper markdown formatting

## Workflow

1. Analyze Requirements - Pause to reason carefully and parse the `USER_PROMPT` to understand the core problem and desired outcome
2. Design Solution - Develop technical approach including architecture decisions and implementation strategy
3. Document Plan - Structure a comprehensive markdown document with problem statement, implementation steps, and testing approach
4. Generate Filename - Create a descriptive kebab-case filename based on the plan's main topic
5. Save & Report - Write the plan to `plan_<name-of-plan>.md` and provide a summary of key components

## Report

After creating and saving the implementation plan, provide a concise report with the following format:

```
✅ Implementation Plan Created

File: plan-<name-of-plan>.md
Topic: <brief description of what the plan covers>
Key Components:
- <main component 1>
- <main component 2>
- <main component 3>
```

Replace placeholders with actual values gathered from the plan.
