# Use Antidote as zsh package manager
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh

zstyle ':omz:plugins:yarn' global-path no
zstyle ':omz:plugins:yarn' berry yes

antidote load
