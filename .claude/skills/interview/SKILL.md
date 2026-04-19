---
name: interview
description: Systematic questioning to clarify requirements, goals, and constraints. Use when there's ambiguity about what the user wants, hidden complexity needs uncovering, or you need to understand before proceeding. Triggers on unclear requirements, vague goals, or when the user says "interview me" or invokes `/interview`.
argument-hint: <topic_or_file>
---

# Interview

## When to Use

- Requirements or goals are ambiguous
- User isn't clear about what they want
- Hidden complexity might derail implementation

Skip when requirements are already clear or user wants to proceed without clarification.

## Starting the Interview

Pick the starting context in this order:

1. **Argument given**: if it looks like a file path, read the file; otherwise treat it as the topic.
2. **Recent conversation**: if there's already a plan, topic, or problem under discussion, use that.
3. **Cold start**: ask the user what they're trying to figure out.

Once you have context, open by asking what's most ambiguous or unclear about it.

## Core Methodology

### Ask Non-Obvious Questions

Probe deeper than surface-level:

- **Why**: What problem does this solve? Why now?
- **Constraints**: What would make this unacceptable? What can't change?
- **Failure modes**: What's the worst case? What happens when X fails?
- **Success**: How will you know this worked? What does "done" look like?
- **Tradeoffs**: What are you willing to give up? Minimum viable version?
- **Assumptions**: You mentioned X, but what about Y? Is that always true?

### Avoid

- Restatements of what's already said
- Yes/no confirmations
- Generic questions that apply to anything
- Leading questions

### Follow the Thread

Dig deeper when answers reveal complexity. Don't jump topics when current one has unexplored depth.

### Batch Questions

Use `AskUserQuestion` with `questions` array for 2-4 related questions exploring different angles of the same area.

## Saturation

Stop when:

- Answers stop revealing new information
- You could explain requirements to someone else
- User expresses readiness to proceed

## Output

Summarize what you've learned:

```
**Clarified Requirements:**
- **Goal**: [specific goal]
- **Constraints**: [hard limits]
- **Success criteria**: [how we'll know it worked]
- **Key tradeoffs**: [prioritizing vs deprioritizing]
- **Open questions**: [if any]
```
