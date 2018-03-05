#!/usr/bin/env zsh

source helpers.sh

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
    set_symlink "$DOTFILES/vscode/projects.json" "$HOME/Library/Application Support/Code/User/projects.json"
fi

# Add defaults
set -e

find . -name "*.install" | while read installer ; do sh -c "${installer}" ; done
