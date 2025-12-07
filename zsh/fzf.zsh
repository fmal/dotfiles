export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
if command -v bat &> /dev/null; then
  fzf_preview_files="bat --style=plain --color=always --line-range :500 {}"
else
  fzf_preview_files="head -n 500 {}"
fi
export FZF_CTRL_T_OPTS="--preview '$fzf_preview_files'"
export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'ls -AF --color=always --group-directories-first {} | head -100'"

FZF_COLORS="fg:gray,\
fg+:-1,\
preview-fg:-1,\
bg:-1,\
bg+:-1,\
hl:underline:-1,\
hl+:underline:white,\
border:gray,\
marker:bright-blue,\
prompt:green,\
pointer:bright-blue,\
spinner:bright-blue"

export FZF_DEFAULT_OPTS="
  --ansi
  --layout=reverse
  --height=~50%
  --info=hidden
  --no-scrollbar
  --no-separator
  --pointer='▶'
  --gutter=' '
  --color=$FZF_COLORS
"

# Load fzf shell integration
source <(fzf --zsh)
