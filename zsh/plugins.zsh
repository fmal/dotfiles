# Use Antidote as zsh package manager
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh

zstyle ':omz:plugins:yarn' global-path no
zstyle ':omz:plugins:yarn' berry yes

antidote load

zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'

zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls -AF --color=always --group-directories-first $realpath'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter
zstyle ':fzf-tab:*' continuous-trigger 'tab'
