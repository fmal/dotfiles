#!/usr/bin/env zsh
# Refresh extensions.txt next to this script, wherever it is run from

code --list-extensions > "${0:A:h}/extensions.txt"
