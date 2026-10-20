#!/bin/bash
# Claude Code status line: model effort · ctx% (tokens/limit at $cost) · dir on branch
# Reads the session JSON from stdin: https://code.claude.com/docs/en/statusline

IFS=$'\t' read -r current_dir model_name usage_pct context_tokens context_limit session_cost effort < <(
  jq -r '[
    .workspace.current_dir,
    .model.display_name,
    (.context_window.used_percentage // 0 | floor),
    (.context_window.total_input_tokens // 0),
    (.context_window.context_window_size // 0),
    (.cost.total_cost_usd // 0),
    (.effort.level // "")
  ] | @tsv'
)

RED=$'\033[31m' GREEN=$'\033[32m' YELLOW=$'\033[33m' BLUE=$'\033[34m'
WHITE=$'\033[37m' GRAY=$'\033[90m' NC=$'\033[0m'
BRANCH_CHAR='' SEP="${GRAY}·${NC}"

# 125000 -> 125k, 1250000 -> 1.2M (truncated, not rounded)
format_tokens() {
  if (( $1 >= 1000000 )); then printf '%d.%dM' $(( $1 / 1000000 )) $(( $1 % 1000000 / 100000 ))
  elif (( $1 >= 1000 )); then printf '%dk' $(( $1 / 1000 ))
  else printf '%d' "$1"
  fi
}

status_line="${YELLOW}${model_name}${NC}"
[[ -n $effort ]] && status_line+=" ${effort}"

if (( context_limit > 0 )); then
  (( usage_pct >= 70 )) && ctx_color=$RED || ctx_color=$GREEN
  details="$(format_tokens "$context_tokens")/$(format_tokens "$context_limit")"
  [[ $session_cost != 0 ]] && printf -v details '%s at $%.2f' "$details" "$session_cost"
  status_line+=" ${SEP} ${ctx_color}${usage_pct}%${NC} ${GRAY}(${details})${NC}"
fi

status_line+=" ${SEP} ${BLUE}${current_dir##*/}${NC}"

# branch name, or the short SHA when HEAD is detached (rebase, checkout of a commit)
git_ref=$(git -C "$current_dir" symbolic-ref --short -q HEAD 2>/dev/null)
[[ -z $git_ref ]] && sha=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null) && git_ref="detached @$sha"
[[ -n $git_ref ]] && status_line+=" on ${WHITE}${BRANCH_CHAR} ${git_ref}${NC}"

printf '%s\n' "$status_line"
