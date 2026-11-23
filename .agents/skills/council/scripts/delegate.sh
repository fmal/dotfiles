#!/usr/bin/env bash
# Run one council delegate headless and read-only.
# Usage: delegate.sh MEMBER DIR [MODEL]
#   MEMBER  claude | codex | agy
#   DIR     holds prompt.md; the reply goes to DIR/MEMBER.md
#   MODEL   overrides the CLI's configured default model
set -euo pipefail

member=${1:?usage: delegate.sh claude|codex|agy DIR [MODEL]} dir=${2:?missing DIR} model=${3:-}
prompt="$dir/prompt.md" out="$dir/$member.md"

# Read-only: all three run shell commands in a sandbox without network.
# Claude's dontAsk denies tools that need approval; its sandbox allows writes
# only to the project, which denyWrite closes (it needs an absolute path), and
# allowUnsandboxedCommands=false stops retries outside it. Codex uses
# -s read-only, and agy's write_file(*) deny blocks file writes and makes its
# sandbox read-only. --setting-sources user and --ignore-rules keep a repo's
# allow rules from loosening Claude or Codex.
# agy: an empty agentMode turns off auto mode, which could leave the sandbox;
# deny rules fail a tool where an approval prompt would end a headless run with
# no output; read_file(*) lets the sandboxed shell read outside the project.
claude_settings=$(jq -cn --arg cwd "$PWD" '{sandbox: {enabled: true, failIfUnavailable: true,
  allowUnsandboxedCommands: false, filesystem: {denyWrite: [$cwd]}}}')
agy_settings='{"agentMode":"","toolPermission":"proceed-in-sandbox","permissions":{"allow":["read_file(*)"],"deny":["write_file(*)","mcp(*)","read_url(*)","execute_url(*)"]}}'

case $member in
  claude) claude -p ${model:+--model "$model"} --permission-mode dontAsk --allowedTools Read,Grep,Glob,Bash --setting-sources user --strict-mcp-config --settings "$claude_settings" <"$prompt" | tee "$out" ;;
  codex) codex exec ${model:+-m "$model"} -s read-only --ignore-rules --skip-git-repo-check -o "$out" - <"$prompt" ;;
  agy) agy ${model:+--model "$model"} --sandbox --settings "$agy_settings" <"$prompt" | tee "$out" ;;
  *) echo "unknown member: $member (expected claude, codex, or agy)" >&2; exit 2 ;;
esac

[[ -s $out ]] || { echo "council: $member exited 0 without a reply" >&2; exit 1; }
