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

# Special case symlink for vscode files
if [[ -d $HOME/Library/Application\ Support/Code/User ]]; then
    set_symlink "$DOTFILES/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    set_symlink "$DOTFILES/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
fi

# Add defaults
set -e

find . -name "*.install" | while read installer ; do sh -c "${installer}" ; done
