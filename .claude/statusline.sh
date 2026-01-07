#!/bin/bash

# Read JSON input
input=$(cat)

# Extract information from Claude context
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_limit=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
context_tokens=$((input_tokens + output_tokens))

# Extract and format cost information
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
cost_display=""
if [ "$session_cost" != "empty" ] && [ -n "$session_cost" ] && [ "$session_cost" != "null" ]; then
  cost_display=$(printf "\$%.2f" "$session_cost")
fi

# Get directory name (basename)
dir_name=$(basename "$current_dir")

# Get git branch if in a git repository
git_branch=""
if git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$current_dir" -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null)
fi

# ANSI color codes
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
WHITE='\033[37m'
GRAY='\033[90m'
NC='\033[0m' # No Color

BRANCH_CHAR=''
SEP_CHAR='·'

# Build the status line starting with model name
short_model=$(echo "$model_name" | sed 's/Claude //' | sed 's/ Sonnet//')

status_line="${YELLOW}${short_model}${NC}"

# Add context window usage with color
if [ "$context_limit" -gt 0 ] 2>/dev/null; then
  usage_pct=$((context_tokens * 100 / context_limit))

  # Format tokens for readability (e.g., 125000 -> 125k)
  format_tokens() {
    local tokens=$1
    if [ "$tokens" -ge 1000000 ]; then
      printf "%.1fM" "$(echo "scale=1; $tokens/1000000" | bc)"
    elif [ "$tokens" -ge 1000 ]; then
      printf "%.0fk" "$(echo "scale=0; $tokens/1000" | bc)"
    else
      printf "%d" "$tokens"
    fi
  }

  tokens_display=$(format_tokens "$context_tokens")
  limit_display=$(format_tokens "$context_limit")

  # Color based on usage: green <70%, red >=70%
  if [ "$usage_pct" -ge 70 ]; then
    ctx_color="$RED"
  else
    ctx_color="$GREEN"
  fi

  # Build details: tokens/limit at cost
  details="${tokens_display}/${limit_display}"
  [ -n "$cost_display" ] && details+=" at ${cost_display}"

  status_line+=" ${GRAY}${SEP_CHAR}${NC} ${ctx_color}${usage_pct}%${NC} ${GRAY}(${details})${NC}"
elif [ -n "$cost_display" ]; then
  status_line+=" ${GRAY}(${cost_display})${NC}"
fi

# Add pipe separator and directory name
status_line+=" ${GRAY}${SEP_CHAR}${NC} ${BLUE}${dir_name}${NC}"

# Add git branch if available
if [[ -n "$git_branch" ]]; then
  status_line+=" on ${WHITE}${BRANCH_CHAR} ${git_branch}${NC}"
fi

echo -e "$status_line"
