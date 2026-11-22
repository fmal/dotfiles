#!/bin/bash
# Antigravity CLI status line: model · ctx% (tokens/limit) · dir on branch · mode
# Reads the session JSON from stdin: https://antigravity.google/docs/cli/statusline

IFS=$'\t' read -r current_dir model_name usage_pct context_tokens context_limit cycle_mode < <(
  jq -r '[
    # read collapses empty tab-separated fields, so "" must become a fallback too
    ((.workspace.current_dir | select(. != "")) // "."),
    ((.model.display_name | select(. != "")) // "—"),
    (.context_window.used_percentage // 0 | floor),
    (.context_window.total_input_tokens // 0),
    (.context_window.context_window_size // 0),
    (.cycle_mode // "")
  ] | @tsv'
)

RED=$'\033[31m' GREEN=$'\033[32m' YELLOW=$'\033[33m' BLUE=$'\033[34m'
MAGENTA=$'\033[35m' WHITE=$'\033[37m' GRAY=$'\033[90m' NC=$'\033[0m'
BRANCH_CHAR='' SEP="${GRAY}·${NC}"

# 125000 -> 125k, 1250000 -> 1.2M (truncated, not rounded)
format_tokens() {
  if (( $1 >= 1000000 )); then printf '%d.%dM' $(( $1 / 1000000 )) $(( $1 % 1000000 / 100000 ))
  elif (( $1 >= 1000 )); then printf '%dk' $(( $1 / 1000 ))
  else printf '%d' "$1"
  fi
}

status_line="${YELLOW}${model_name}${NC}"

if (( context_limit > 0 )); then
  if (( usage_pct >= 70 )); then ctx_color=$RED; else ctx_color=$GREEN; fi
  details="$(format_tokens "$context_tokens")/$(format_tokens "$context_limit")"
  status_line+=" ${SEP} ${ctx_color}${usage_pct}%${NC} ${GRAY}(${details})${NC}"
fi

status_line+=" ${SEP} ${BLUE}${current_dir##*/}${NC}"

# branch name, or the short SHA when HEAD is detached (rebase, checkout of a commit)
git_ref=$(git -C "$current_dir" symbolic-ref --short -q HEAD 2>/dev/null)
[[ -z $git_ref ]] && sha=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null) && git_ref="detached @$sha"
[[ -n $git_ref ]] && status_line+=" on ${WHITE}${BRANCH_CHAR} ${git_ref}${NC}"

[[ -n $cycle_mode ]] && status_line+=" ${SEP} ${MAGENTA}${cycle_mode}${NC}"

printf '%s\n' "$status_line"
