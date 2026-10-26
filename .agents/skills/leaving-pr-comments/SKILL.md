---
name: leaving-pr-comments
description: Use when posting a comment, review, or review reply on GitHub.
---

# Leaving PR comments

Write each comment with the `technical-writing` skill so the reader can act on
it without asking a follow-up:

- Lead with the conclusion.
- Cite the code, check, or reproduction behind it.
- Separate verified facts from judgment.

Text the user dictates goes out exactly as given.

Before posting, check the whole comment, including quoted text and
attachments, for secrets and private details.

Pass the body through a quoted heredoc so the shell posts backticks and `$` as
written.

`gh pr review` always submits. For a pending review, use `gh api` and leave out
`event`. Add thread replies to it with GraphQL `addPullRequestReviewThreadReply`,
passing its `pullRequestReviewId`.

Resolve a review thread only after its reply is visible to others.
