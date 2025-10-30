alias zshconfig="code ~/.zshrc"
alias ss='source ~/.zshrc' # quick source
alias mkdir="mkdir -p"
alias l="ls -al"
alias ls="ls -GFh"
alias ll="ls -GFhl"
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

# Claude Code
if [[ -x "$HOME/.claude/local/claude" ]]; then
  claude() {
    command "$HOME/.claude/local/claude" "$@" --mcp-config "$DOTFILES/.claude/.mcp.json"
  }

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
