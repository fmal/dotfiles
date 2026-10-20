#!/usr/bin/env zsh

source helpers.sh

# Ask for the administrator password upfront and keep the ticket alive until
# the script exits; brew bundle alone can outlast the 5-minute sudo timeout
sudo -v
( while sudo -n true; do sleep 50; done ) &
trap "kill $! 2>/dev/null" EXIT

# Checking file dir
export DOTFILES=$HOME/.dotfiles
[[ ! -d $DOTFILES ]] && die "Directory ~/.dotfiles is missing"

for symlink ($DOTFILES/**/*.symlink) {
  filename=${${symlink%.symlink}##*\/}

  set_symlink "$symlink" "$HOME/.$filename"
}

# Symlink configs
mkdir -p "$HOME/.config/husky"
set_symlink "$DOTFILES/.config/husky/init.sh" "$HOME/.config/husky/init.sh"

mkdir -p "$HOME/.config/gh"
set_symlink "$DOTFILES/.config/gh/config.yml" "$HOME/.config/gh/config.yml"

mkdir -p "$HOME/.config/mise"
set_symlink "$DOTFILES/.config/mise/config.toml" "$HOME/.config/mise/config.toml"

# ssh: generic client config only; host blocks live in ~/.ssh/config.local (untracked)
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
set_symlink "$DOTFILES/ssh/config" "$HOME/.ssh/config"

# fnox secrets (age key at ~/.config/fnox/age.txt is machine-local, not in repo)
mkdir -p "$HOME/.config/fnox"
set_symlink "$DOTFILES/.config/fnox/config.toml" "$HOME/.config/fnox/config.toml"

set_symlink "$DOTFILES/.config/starship.toml" "$HOME/.config/starship.toml"

set_symlink "$DOTFILES/.config/ghostty" "$HOME/.config/ghostty"

set_symlink "$DOTFILES/.config/bat" "$HOME/.config/bat"

# JankyBorders (brew 'borders') runs bordersrc as its startup script
mkdir -p "$HOME/.config/borders"
set_symlink "$DOTFILES/.config/borders/bordersrc" "$HOME/.config/borders/bordersrc"

# lazygit reads from Application Support on macOS (no XDG_CONFIG_HOME set)
mkdir -p "$HOME/Library/Application Support/lazygit"
set_symlink "$DOTFILES/.config/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"

# Symlink mackup custom application definitions
mkdir -p "$HOME/.config/mackup"
set_symlink "$DOTFILES/mackup/applications" "$HOME/.config/mackup/applications"

# Symlink agents (skills) conf
set_symlink "$DOTFILES/.agents" "$HOME/.agents"

# Symlink claude code conf
mkdir -p "$HOME/.claude"
set_symlink "$DOTFILES/.claude/settings.json" "$HOME/.claude/settings.json"
set_symlink "$DOTFILES/.agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
set_symlink "$DOTFILES/.claude/commands" "$HOME/.claude/commands"
set_symlink "$DOTFILES/.claude/skills" "$HOME/.claude/skills"
set_symlink "$DOTFILES/.claude/statusline.sh" "$HOME/.claude/statusline.sh"

# Symlink gemini CLI conf
mkdir -p "$HOME/.gemini"
set_symlink "$DOTFILES/.gemini/settings.json" "$HOME/.gemini/settings.json"
set_symlink "$DOTFILES/.agents/AGENTS.md" "$HOME/.gemini/AGENTS.md"

# Symlink codex CLI conf
mkdir -p "$HOME/.codex"
set_symlink "$DOTFILES/.codex/config.toml" "$HOME/.codex/config.toml"
set_symlink "$DOTFILES/.agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
set_symlink "$DOTFILES/.codex/prompts" "$HOME/.codex/prompts"
set_symlink "$DOTFILES/.codex/themes" "$HOME/.codex/themes"

# write Docker config file (don't link, because auth)
mkdir -p "$HOME/.docker"
cat "$DOTFILES/.docker/config.json" > "$HOME/.docker/config.json"

set -e

# Homebrew first, the rest in sorted order. (u) drops homebrew's duplicate from
# the glob; (D) includes dot-dirs like .claude
installers=($DOTFILES/homebrew/homebrew.install $DOTFILES/**/*.install(D))
for installer (${(u)installers}) run_installer "$installer"

# Ghostty's terminfo lives in its app bundle, which only Ghostty's own shells
# search. Copy it to ~/.terminfo so SSH sessions recognize TERM=xterm-ghostty.
if [[ -d /Applications/Ghostty.app ]]; then
  mkdir -p "$HOME/.terminfo"
  TERMINFO=/Applications/Ghostty.app/Contents/Resources/terminfo infocmp -x xterm-ghostty \
    | tic -x -o "$HOME/.terminfo" - \
    || echo "Warning: couldn't install xterm-ghostty terminfo"
fi

# don't show last login message
if [[ ! -f $HOME/.hushlogin ]]; then
  touch $HOME/.hushlogin
fi
