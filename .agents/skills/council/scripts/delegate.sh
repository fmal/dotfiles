#!/usr/bin/env bash
# Run one council delegate headless and read-only.
# Usage: delegate.sh MEMBER DIR [MODEL]
#   MEMBER  claude | codex
#   DIR     holds prompt.md; the reply goes to DIR/MEMBER.md
#   MODEL   overrides the CLI's configured default model
set -euo pipefail

member=${1:?usage: delegate.sh claude|codex DIR [MODEL]} dir=${2:?missing DIR} model=${3:-}
prompt="$dir/prompt.md" out="$dir/$member.md"

# Read-only: Claude's dontAsk denies anything that would need approval, and
# Codex's sandbox blocks writes by shell commands. --setting-sources user and
# --ignore-rules keep a repo's own allow rules from loosening that.
# --allowedTools lets Claude read and search outside the project, as Codex can.
# --strict-mcp-config skips Claude's MCP servers, which a review doesn't need.
case $member in
  claude) claude -p ${model:+--model "$model"} --permission-mode dontAsk --allowedTools Read,Grep,Glob --setting-sources user --strict-mcp-config <"$prompt" | tee "$out" ;;
  codex) codex exec ${model:+-m "$model"} -s read-only --ignore-rules --skip-git-repo-check -o "$out" - <"$prompt" ;;
  *) echo "unknown member: $member (expected claude or codex)" >&2; exit 2 ;;
esac

[[ -s $out ]] || { echo "council: $member exited 0 without a reply" >&2; exit 1; }
