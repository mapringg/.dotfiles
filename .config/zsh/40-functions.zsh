brk() {
  command -v fd >/dev/null 2>&1 || return

  fd --hidden --type l \
    --exclude node_modules \
    --exclude .git \
    --exclude .cache \
    --exclude Library \
    . ~ \
    --exec sh -c 'test ! -e "$1" && echo "$1"' _ {}
}

fcd() {
  local dir

  command -v fd >/dev/null 2>&1 || return
  command -v fzf >/dev/null 2>&1 || return

  dir="$(fd --hidden --type d --exclude .git . "${1:-.}" | fzf --reverse --prompt='cd> ')" || return
  cd "$dir" || return
}

fe() {
  local file

  command -v bat >/dev/null 2>&1 || return
  command -v fd >/dev/null 2>&1 || return
  command -v fzf >/dev/null 2>&1 || return

  file="$(fd --hidden --type f . "${1:-.}" | fzf --reverse --prompt='edit> ' --preview 'bat --color=always --style=plain --line-range=:200 {}')" || return
  "${EDITOR:-nvim}" "$file"
}

fkill() {
  local pid
  local -a ps_cmd

  command -v fzf >/dev/null 2>&1 || return

  if [[ "$(uname -s)" == Darwin ]]; then
    ps_cmd=(ps -Ao pid=,comm=,%cpu=,%mem= -r)
  else
    ps_cmd=(ps -eo pid=,comm=,%cpu=,%mem= --sort=-%cpu)
  fi

  pid="$("${ps_cmd[@]}" | fzf --reverse --prompt='kill pid> ' | awk '{print $1}')" || return
  [[ -n "$pid" ]] || return
  kill -15 "$pid"
}

gcof() {
  local branch

  command -v fzf >/dev/null 2>&1 || return
  git rev-parse --git-dir >/dev/null 2>&1 || return

  branch="$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads refs/remotes | grep -v '^origin/HEAD$' | sed 's#^origin/##' | awk '!seen[$0]++' | fzf --reverse --prompt='checkout> ')" || return
  [[ -n "$branch" ]] || return
  git checkout "$branch"
}

ghprf() {
  local pr

  command -v gh >/dev/null 2>&1 || return
  command -v fzf >/dev/null 2>&1 || return

  pr="$(gh pr list --limit 200 | fzf --reverse --prompt='pr> ' | awk '{print $1}')" || return
  [[ -n "$pr" ]] || return
  gh pr checkout "$pr"
}

n() {
  if [[ "$#" -eq 0 ]]; then
    nvim .
  else
    nvim "$@"
  fi
}

tf() {
  local cmd

  command -v fzf >/dev/null 2>&1 || return
  command -v tldr >/dev/null 2>&1 || return

  cmd="$(tldr --list | fzf --reverse --prompt='tldr> ')" || return
  [[ -n "$cmd" ]] || return
  tldr "$cmd"
}

tms() {
  local selected session_name tmux_running
  local -a SEARCH_DIRS
  local existing_sessions all_dirs

  SEARCH_DIRS=(
    "$HOME/.dotfiles"
    "$HOME/code"
  )

  if [[ $# -eq 1 ]]; then
    selected=$1
  else
    command -v fzf >/dev/null 2>&1 || return

    existing_sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)

    all_dirs=$(
      find "${SEARCH_DIRS[@]}" -maxdepth 2 -type d -name ".git" 2>/dev/null |
        sed 's|/.git$||' |
        while read -r dir; do
          echo "${dir/#$HOME\//}" | sed 's|^code/||'
        done |
        sort
    )

    selected=$(
      {
        echo "$existing_sessions" | while read -r session; do
          [[ -n "$session" ]] && echo "● $session"
        done

        [[ -n "$existing_sessions" ]] && echo "──────────────────"

        echo "$all_dirs" | while read -r dir; do
          session_name=$(echo "$dir" | tr '.:' '__')
          if ! echo "$existing_sessions" | grep -qx "$session_name"; then
            echo "$dir"
          fi
        done
      } |
        fzf
    )

    [[ "$selected" == "──────────────────" ]] && return 0

    if [[ "$selected" == "● "* ]]; then
      session_name="${selected#● }"
      if [[ -z "$TMUX" ]]; then
        tmux attach-session -t "$session_name"
      else
        tmux switch-client -t "$session_name"
      fi
      return 0
    fi
  fi

  [[ -z "$selected" ]] && return 0

  if [[ "$selected" != /* ]]; then
    if [[ -d "$HOME/code/$selected" ]]; then
      selected="$HOME/code/$selected"
    elif [[ -d "$HOME/$selected" ]]; then
      selected="$HOME/$selected"
    else
      echo "Directory not found: $selected" >&2
      return 1
    fi
  fi

  session_name=$(echo "$selected" | sed "s|$HOME/||" | sed "s|^code/||" | tr '.:' '__')
  tmux_running=$(pgrep tmux)

  if [[ -z "$TMUX" ]] && [[ -z "$tmux_running" ]]; then
    tmux new-session -ds "$session_name" -c "$selected"
    tmux attach-session -t "$session_name"
    return 0
  fi

  if ! tmux has-session -t="$session_name" 2>/dev/null; then
    tmux new-session -ds "$session_name" -c "$selected"
  fi

  if [[ -z "$TMUX" ]]; then
    tmux attach-session -t "$session_name"
  else
    tmux switch-client -t "$session_name"
  fi
}
