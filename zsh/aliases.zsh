alias zshconfig="code ~/.zshrc"
alias ss='source ~/.zshrc' # quick source
alias mkdir="mkdir -p"
alias ls="ls -hF --color=auto --group-directories-first"
alias la="ls -A"
alias ll="ls -l"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias o="open ./"
alias f="finder"
alias projects="cd ~/Code"
alias desktop="cd ~/Desktop"
# will copy folder contents, if folder ends in / will copy contents, not folder itself
alias copy="cp -r"
alias delete="rm -r"

if command -v zoxide &> /dev/null; then
  # Only remap cd in interactive shells
  if [[ -o interactive ]]; then
    alias cd="z"
    alias cdi="zi"  # interactive mode
  fi
fi

# redirect stderr to /dev/null global alias
alias -g NE='2>/dev/null'

# Claude Code
if [[ -x "$HOME/.claude/local/claude" ]]; then
  alias claude="$HOME/.claude/local/claude"
  alias claude-yolo="claude --dangerously-skip-permissions"
fi

# Codex
if command -v codex &> /dev/null; then
  alias codex-yolo="codex --dangerously-bypass-approvals-and-sandbox -c shell_environment_policy.ignore_default_excludes=true"
fi

# Inkscape
if [[ -f "/Applications/Inkscape.app/Contents/Resources/bin/inkscape" ]]; then
  alias inkscape="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
fi
