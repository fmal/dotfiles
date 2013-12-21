#!/usr/bin/env zsh

# Helper to exit and display an error message
die () {
  echo
  echo $(basename $0): ${1:-"Unknown Error"} 1>&2
  exit 1
}

# Checking file dir
DOTFILES=$HOME/.dotfiles
[ ! -d $DOTFILES ] && die "Directory ~/.dotfiles is missing"

for symlink ($DOTFILES/**/*.symlink) {
  filename=${${symlink%.symlink}##*\/}

  if [ -f "$HOME/.$filename" ]; then # if exists
    if [ ! -h "$HOME/.$filename" ]; then # if is not a symlink
      echo "✖ File .$filename exists, and is not a symlink; creating backup: $HOME/.$filename.old"
      cp $HOME/.$filename $HOME/.$filename.old
    fi
    rm -r $HOME/.$filename
  fi

  ln -s "$symlink" "$HOME/.$filename"
  echo "symlink $symlink  ➠  ~/.$filename"
}

# Add defaults
set -e

find . -name "*.install" | while read installer ; do sh -c "${installer}" ; done
