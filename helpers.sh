#!/usr/bin/env zsh

# Helper to exit and display an error message
die () {
  echo
  echo $(basename $0): ${1:-"Unknown Error"} 1>&2
  exit 1
}

run_installer () {
	installer=$1
	echo "Running ${installer}"
	sh -c "${installer}"
}

set_symlink () {
  overwrite_all=${overwrite_all:-false}
  backup_all=${backup_all:-false}
  skip_all=${skip_all:-false}

  local link_target="$1:A" link_file="$2"

  local overwrite='' backup='' skip=''
  local action=''

  if [ -f "$link_file" -o -d "$link_file" -o -L "$link_file" ]; then

    if [ "$overwrite_all" = "false" ] && [ "$backup_all" = "false" ] && [ "$skip_all" = "false" ]; then

      local current_link_target
      current_link_target="$link_file:A"

      if [ "$current_link_target" = "$link_target" ]; then
        skip=true;
      else
        echo "⚠ File already exists: $link_target ($(basename "$link_target")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -k action

        case "$action" in
          o ) overwrite=true;;
          O ) overwrite_all=true;;
          b ) backup=true;;
          B ) backup_all=true;;
          s ) skip=true;;
          S ) skip_all=true;;
          * ) ;;
        esac
      fi
    fi

    overwrite="${overwrite:-$overwrite_all}"
    backup="${backup:-$backup_all}"
    skip="${skip:-$skip_all}"

    if [ "$overwrite" = "true" ]; then
      rm -rf "$link_file"
      echo "Removed $link_file"
    fi

    if [ "$backup" = "true" ]; then
      mv "$link_file" "${link_file}.backup"
      echo "Moved $link_file to ${link_file}.backup"
    fi

    if [ "$skip" = "true" ]; then
      echo "Skipped $link_target"
    fi
  fi

  if [ "$skip" != "true" ]; then
    ln -s "$1" "$2"
    echo "Linked $1 ➠ $2"
  fi
}

