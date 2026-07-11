---
name: create-spec
description: Turn the current conversation context into a spec and submit it as a GitHub issue. Use when the user wants to create a spec from the current context, or invokes `/create-spec`.
disable-model-invocation: true
argument-hint: <feature description>
---

# Create Spec

Synthesize what you already know — from the argument, conversation, or codebase — into a spec (you may know this document as a PRD), then submit it as a GitHub issue. Do NOT interview the user.

If there's no prior conversation, plan, or argument to synthesize from, stop and ask the user to provide context.

## Process

1. **Explore the repo** to understand the current state of the codebase, if you haven't already. Before exploring, follow [../domain-modeling/DOMAIN-AWARENESS.md](../domain-modeling/DOMAIN-AWARENESS.md). Use the project's `CONTEXT.md` vocabulary throughout the spec.

2. **Sketch the major modules** you will need to build or modify. Actively look for opportunities to extract deep modules that can be tested in isolation.

   A deep module (as opposed to a shallow module) encapsulates a lot of functionality behind a simple, testable interface that rarely changes.

   Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

3. **Write the spec** using the template below and submit it as a GitHub issue via `gh issue create`. If the working directory is not a GitHub repo, or `gh` is not authenticated, write the spec to `SPEC.md` in the working directory instead and tell the user why you fell back.

## Spec Template

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list should be extremely extensive and cover all aspects of the feature.

## Definition of Done

Concrete, checkable outcomes that tell us the feature worked — observable behaviours or conditions that hold once it ships, not product KPIs. Each should be verifiable (a check that passes, a behaviour that now holds), not a vague goal.

## Non-Functional Requirements

Performance, security, accessibility, and usability constraints the feature must satisfy.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
