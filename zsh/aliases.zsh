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
if command -v claude &> /dev/null; then
  alias claude!="claude --dangerously-skip-permissions"
  alias cc="claude"
  alias cc!="claude!"
fi

# Codex
if command -v codex &> /dev/null; then
  alias codex!="codex --dangerously-bypass-approvals-and-sandbox -c shell_environment_policy.ignore_default_excludes=true"
fi

# lazygit that cd's into the last repo you visited (via the repo switcher)
if command -v lazygit &> /dev/null; then
  lg() {
    export LAZYGIT_NEW_DIR_FILE="$HOME/.lazygit/newdir"
    lazygit "$@"
    if [[ -f "$LAZYGIT_NEW_DIR_FILE" ]]; then
      cd "$(cat "$LAZYGIT_NEW_DIR_FILE")"
      rm -f "$LAZYGIT_NEW_DIR_FILE"
    fi
  }
fi

# ssh that auto-reconnects after sleep/network drops
if command -v autossh &> /dev/null; then
  alias ash='autossh -M 0 -q'
fi
