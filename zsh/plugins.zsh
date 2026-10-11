# Use Antidote as zsh package manager
source "$HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh"

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=black,bg=cyan'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=black,bg=red'

antidote load

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
zstyle ':completion:*:git-checkout:*' sort false  # ignore order on git checkout

zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*' fzf-min-height 15
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter
zstyle ':fzf-tab:*' continuous-trigger 'tab'
zstyle ':fzf-tab:*' show-group none

zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls -AF --color=always --group-directories-first $realpath'
zstyle ':fzf-tab:complete:git-(add|restore):*' fzf-preview 'git diff --color=always $realpath | diff-so-fancy'
zstyle ':fzf-tab:complete:git-diff:*' fzf-preview 'git diff --color=always $word | diff-so-fancy'
zstyle ':fzf-tab:complete:git-(checkout|branch|log):*' fzf-preview 'git log --graph --oneline --color=always -n 25 $word'
