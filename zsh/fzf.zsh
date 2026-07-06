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
  --height=50%
  --min-height=15
  --info=hidden
  --no-scrollbar
  --no-separator
  --pointer='▶'
  --gutter=' '
  --color=$FZF_COLORS
"

# Load fzf shell integration
source <(fzf --zsh)

if command -v zmx &> /dev/null; then
  # For hosts I SSH into regularly, prefer per-session aliases over the picker
  # below — pattern documented in ~/.ssh/config.

  # zmx session picker (https://zmx.sh/#session-picker)
  zmx-select() {
    local display
    display=$(zmx list 2>/dev/null | while IFS=$'\t' read -r name pid clients created dir; do
      name=${name#*name=}
      pid=${pid#pid=}
      clients=${clients#clients=}
      dir=${dir#start_dir=}
      printf "%-20s  pid:%-8s  clients:%-2s  %s\n" "$name" "$pid" "$clients" "$dir"
    done)

    local output rc query key selected session_name
    output=$({ [[ -n "$display" ]] && echo "$display"; } | fzf \
      --print-query \
      --expect=ctrl-n \
      --height=80% \
      --prompt="zmx> " \
      --header="enter: select | ctrl-n: create new" \
      --preview='zmx history {1}' \
      --preview-window=right:60%:follow)
    rc=$?

    query=$(echo "$output" | sed -n '1p')
    key=$(echo "$output" | sed -n '2p')
    selected=$(echo "$output" | sed -n '3p')

    if [[ "$key" == "ctrl-n" && -n "$query" ]]; then
      session_name="$query"
    elif [[ $rc -eq 0 && -n "$selected" ]]; then
      session_name=$(echo "$selected" | awk '{print $1}')
    elif [[ -n "$query" ]]; then
      session_name="$query"
    else
      return 130
    fi

    zmx attach "$session_name"
  }

  # ctrl-g opens the picker; no-op when already inside a session
  zmx-select-widget() {
    [[ -n "$ZMX_SESSION" ]] && return
    zle push-input
    BUFFER="zmx-select"
    zle accept-line
  }
  zle -N zmx-select-widget
  bindkey '^g' zmx-select-widget

  # Auto-launch the picker when connecting over SSH; exit the outer shell on detach
  if [[ -n "$SSH_CONNECTION" && -z "$ZMX_SESSION" ]]; then
    zmx-select && exit
  fi
fi
