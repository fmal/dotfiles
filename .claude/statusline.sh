#!/bin/bash

# Read JSON input
input=$(cat)

# Extract information from Claude context
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
# Extract cost information
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
[ "$session_cost" != "empty" ] && session_cost=$(printf "%.4f" "$session_cost") || session_cost=""

# Get directory name (basename)
dir_name=$(basename "$current_dir")

# Get git branch if in a git repository
git_branch=""
if git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
fi

# ANSI color codes
ORANGE='\033[33m'
BLUE='\033[34m'
WHITE='\033[37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

BRANCH_CHAR=''

# Build the status line starting with model name
status_line="${ORANGE}${model_name}${NC}"

# Add session cost if available
if [ -n "$session_cost" ] && [ "$session_cost" != "null" ] && [ "$session_cost" != "empty" ]; then
  status_line+=" ${GRAY}(\$$session_cost)${NC}"
fi

# Add pipe separator and directory name
status_line+=" | ${BLUE}${dir_name}${NC}"

# Add git branch if available
if [[ -n "$git_branch" ]]; then
  status_line+=" on ${WHITE}${BRANCH_CHAR} ${git_branch}${NC}"
fi

echo -e "$status_line"
