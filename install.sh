#!/usr/bin/env zsh

source helpers.sh

# Ask for the administrator password upfront
sudo -v

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

set_symlink "$DOTFILES/.config/ghostty" "$HOME/.config/ghostty"

# Symlink claude code conf
mkdir -p "$HOME/.claude"
set_symlink "$DOTFILES/.claude/settings.json" "$HOME/.claude/settings.json"
set_symlink "$DOTFILES/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
set_symlink "$DOTFILES/.claude/commands" "$HOME/.claude/commands"
set_symlink "$DOTFILES/.claude/statusline.sh" "$HOME/.claude/statusline.sh"

# Symlink gemini CLI conf
mkdir -p "$HOME/.gemini"
set_symlink "$DOTFILES/.gemini/settings.json" "$HOME/.gemini/settings.json"
set_symlink "$DOTFILES/.gemini/GEMINI.md" "$HOME/.gemini/GEMINI.md"

# Symlink codex CLI conf
mkdir -p "$HOME/.codex"
set_symlink "$DOTFILES/.codex/config.toml" "$HOME/.codex/config.toml"
set_symlink "$DOTFILES/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md"

# write Docker config file (don't link, because auth)
mkdir -p "$HOME/.docker"
cat "$DOTFILES/.docker/config.json" > "$HOME/.docker/config.json"

set -e

# Before running any install scripts, make sure homebrew is installed
run_installer "./homebrew/homebrew.install"

# Find generic installers and run them iteratively
for installer in $(find . -name "*.install" | grep -v "homebrew"); do
  run_installer $installer
done

# don't show last login message
if [[ ! -f $HOME/.hushlogin ]]; then
  touch $HOME/.hushlogin
fi
