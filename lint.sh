#!/usr/bin/env bash
# Run shellcheck on sh/bash scripts and `zsh -n` on zsh scripts, classified by
# shebang (sourced sh files declare `# shellcheck shell=...` on line 1 instead).
# Skills vendored from upstream (.agents/.skill-lock.json) are skipped.
set -euo pipefail
cd "$(dirname "$0")"

vendored=$(jq -r '.skills | keys | join("|")' .agents/.skill-lock.json)
sh_files=()
zsh_files=(zsh/*.zsh zsh/zshrc.symlink zsh/zprofile.symlink)   # sourced, no shebang

while IFS= read -r file; do
  [[ -f $file && ! -L $file && ! $file =~ ^\.agents/skills/($vendored)/ ]] || continue
  read -r first_line < "$file" || true
  case $first_line in
    '#!'*bash | '#!/bin/sh' | '# shellcheck shell='*) sh_files+=("$file") ;;
    '#!'*zsh) zsh_files+=("$file") ;;
  esac
done < <(git ls-files)

shellcheck "${sh_files[@]}"
for file in "${zsh_files[@]}"; do zsh -n "$file"; done
echo "OK: ${#sh_files[@]} files shellchecked, ${#zsh_files[@]} zsh files parsed"
