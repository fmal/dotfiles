---
name: deep-code-quality-review
description: An extremely strict maintainability audit for abstraction quality, giant files, and spaghetti-condition growth. Use for a deep code quality review, code quality audit, or harsh maintainability review.
disable-model-invocation: true
---

# Deep Code Quality Review

Use this skill for an unusually strict review focused on implementation quality, maintainability, abstraction quality, and codebase health.

Be **ambitious** about structure. Don't stop at local cleanup or rubber-stamp code that merely works — hunt for "code judo": a restructuring that uses the existing architecture to make the change dramatically simpler, smaller, and more direct. Prefer *deleting* complexity over rearranging it, and prefer the version that makes the code feel inevitable in hindsight. Don't settle for renaming when the problem is structural, or for a tidier version of the same messy idea when a simpler idea is available.

## Core Prompt

Start from this baseline:

> Perform a deep code quality audit of the current branch's changes.
> Rethink how to structure / implement the changes to meaningfully improve code quality without impacting behavior.
> Work to improve abstractions, modularity, reduce Spaghetti code, improve succinctness and legibility.
> Be ambitious, if there is a clear path to improving the implementation that involves restructuring some of the codebase, go for it.
> Be extremely thorough and rigorous. Measure twice, cut once.

A diff is a starting point, not a boundary: look across the whole codebase for the cleaner structure, starting from this branch's changes.

## Review Principles

Ask of every meaningful change:

- **Is there a code-judo move that makes this dramatically simpler?**
- **Can it be reframed so fewer concepts, branches, or helper layers are needed?**

Then apply each principle below. Each bundles the standard, the smell to flag, the fix to prefer, and how to say it.

### 1. Keep files navigable
Don't let a PR push a file from under 1k lines to over 1k without a strong reason — big files are hard to navigate and burn context. Treat the crossing as a strong smell and ask whether to decompose first; waive only when the result is still clearly organized.
*Fix:* extract helpers, subcomponents, or modules; split the file along its seams.
*Say it like:* `this pushes the file past 1k lines. can we decompose this first?`

### 2. No spaghetti conditionals
Be suspicious of ad-hoc conditionals, scattered special cases, and one-off branches bolted onto unrelated flows — including edge cases buried in an already busy function and "temporary" branches that will become permanent debt. Weird if-statements in random places are a design problem, not a stylistic nit, even when they work.
*Fix:* push the logic into a dedicated abstraction, helper, state machine, policy object, or module; replace condition chains with a typed model or explicit dispatcher; collapse duplicate branches and turn special cases into a simpler default with fewer exceptions.
*Say it like:* `this adds another special-case branch into an already busy flow. can we move this behind its own abstraction?`

### 3. Direct over magical
Prefer direct, boring, maintainable code over hacky or magical code. Be skeptical of generic mechanisms that hide simple data-shape assumptions, and of thin wrappers, identity abstractions, or pass-through helpers that add indirection without buying clarity.
*Fix:* delete the layer of indirection rather than polishing it, and keep the direct flow.
*Say it like:* `this abstraction seems unnecessary. can we just keep the direct flow?`

### 4. Clean types and boundaries
Question unnecessary optionality, `unknown`, `any`, or cast-heavy code when a clearer type boundary could exist. Prefer explicit typed models or shared contracts over loosely-shaped ad-hoc objects. If a branch leans on a silent fallback to paper over an unclear invariant, make the boundary explicit instead.
*Fix:* tighten the type boundary so the control flow gets simpler.
*Say it like:* `why does this need a cast / optional here? can we make the boundary more explicit instead?`

### 5. Canonical layer and reuse
Keep logic in the layer that owns it. Call out feature logic leaking into shared paths, implementation details leaking through APIs, and copy-pasted code where a canonical helper already exists. Don't normalize architectural drift.
*Fix:* reuse the existing canonical helper; move the logic to the package or module that owns the concept; change the ownership boundary so the feature becomes a natural extension of an existing abstraction.
*Say it like:* `this looks like a bespoke helper for something we already have elsewhere. can we reuse the canonical one?`

### 6. Parallel and atomic flow
Run independent work in parallel and keep related updates atomic. Flag steps serialized for no reason, and updates that can leave state half-applied. Don't chase micro-optimizations — only call out orchestration that is needlessly sequential or brittle, especially when the simpler structure also reads better.
*Fix:* parallelize independent work where it also simplifies the flow; separate orchestration from business logic; restructure related updates so partial state isn't possible.
*Say it like:* `these steps are independent — running them in parallel would be simpler and faster. is the sequencing load-bearing?`

## Reporting

Lead with the biggest structural issues; don't bury them under nits. Prioritize:

1. Structural regressions and missed code-judo simplifications
2. Spaghetti / branching growth (principle 2)
3. Type and boundary problems that obscure the real invariant (principle 4)
4. File-size and decomposition concerns (principle 1)
5. Magic, wrappers, and canonical-layer leaks (principles 3, 5)
6. Remaining legibility and maintainability notes

Prefer a few high-conviction comments over a long list of cosmetic ones. Be direct and demanding about quality — name a mess as a mess — but not rude.

## Approval Bar

Correct behavior is not enough. Block (presumptively, unless the author justifies it) when the PR:

- preserves incidental complexity that a visible code-judo move would delete
- crosses the 1k-line file threshold without a strong reason
- adds ad-hoc branching that tangles an existing flow
- scatters feature-specific checks across shared code
- adds an unnecessary wrapper, magic mechanism, or cast/optionality churn that makes the design more indirect
- duplicates an existing helper or puts logic in the wrong layer

Otherwise, leave explicit, actionable feedback and push for the cleaner decomposition.
