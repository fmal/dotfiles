#!/usr/bin/env zsh

source helpers.sh

# Ask for the administrator password upfront
sudo -v

# Checking file dir
DOTFILES=$HOME/.dotfiles
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
