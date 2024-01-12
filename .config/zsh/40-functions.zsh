b() {
  command -v fd >/dev/null 2>&1 || return

  fd --hidden --type l \
    --exclude node_modules \
    --exclude .git \
    --exclude .cache \
    --exclude Library \
    . ~ \
    --exec sh -c 'test ! -e "$1" && echo "$1"' _ {}
}

ff() {
  local file

  command -v bat >/dev/null 2>&1 || return
  command -v fd >/dev/null 2>&1 || return
  command -v fzf >/dev/null 2>&1 || return

  file="$(fd --hidden --type f . "${1:-.}" | fzf --reverse --prompt='edit> ' --preview 'bat --color=always --style=plain --line-range=:200 {}')" || return
  "${EDITOR:-nvim}" "$file"
}

fp() {
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

t() {
  local all_dirs cache_age cache_dir cache_file cache_mtime cache_tmp existing_sessions legacy_cache_file selected session_name
  local key project session
  local -A session_lookup
  local -a SEARCH_DIRS

  SEARCH_DIRS=(
    "$HOME/.dotfiles"
    "$HOME/code"
  )

  if [[ $# -eq 1 ]]; then
    selected=$1
  else
    command -v fd >/dev/null 2>&1 || return
    command -v fzf >/dev/null 2>&1 || return

    cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
    cache_file="$cache_dir/t"
    legacy_cache_file="$cache_dir/t-projects"

    mkdir -p "$cache_dir"
    if [[ ! -s "$cache_file" ]] && [[ -s "$legacy_cache_file" ]]; then
      mv -f "$legacy_cache_file" "$cache_file"
    fi

    if [[ -s "$cache_file" ]]; then
      all_dirs="$(<"$cache_file")"
      cache_mtime=$(stat -f '%m' "$cache_file")
      cache_age=$(( $(date +%s) - cache_mtime ))
      if (( cache_age >= 120 )); then
        cache_tmp="$cache_file.$$"
        (
          fd --type d --hidden --no-ignore --glob '.git' --max-depth 3 "${SEARCH_DIRS[@]}" 2>/dev/null |
            sed "s|/.git/$||; s|^$HOME/||; s|^code/||" |
            sort >| "$cache_tmp" &&
            mv -f "$cache_tmp" "$cache_file"
        ) >/dev/null 2>&1 &!
      fi
    else
      all_dirs=$(
        fd --type d --hidden --no-ignore --glob '.git' --max-depth 3 "${SEARCH_DIRS[@]}" 2>/dev/null |
          sed "s|/.git/$||; s|^$HOME/||; s|^code/||" |
          sort
      )
      printf '%s\n' "$all_dirs" >| "$cache_file"
    fi

    existing_sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
    while IFS= read -r session; do
      [[ -n "$session" ]] || continue
      session_lookup[${session//[.:]/_}]=1
    done <<< "$existing_sessions"

    selected=$(
      {
        [[ -n "$existing_sessions" ]] && sed 's/^/ /' <<< "$existing_sessions"
        while IFS= read -r project; do
          [[ -n "$project" ]] || continue
          key=${project//[.:]/_}
          [[ -n "${session_lookup[$key]}" ]] && continue
          printf ' %s\n' "$project"
        done <<< "$all_dirs"
      } |
        fzf --cycle --no-sort
    ) || return
  fi

  [[ -z "$selected" ]] && return 0

  if [[ "$selected" == " "* ]]; then
    selected="${selected# }"
    if [[ -z "$TMUX" ]]; then
      tmux attach-session -t "$selected"
    else
      tmux switch-client -t "$selected"
    fi
    return 0
  fi

  selected="${selected# }"

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

  session_name="${selected#"$HOME/"}"
  session_name="${session_name#code/}"
  session_name="${session_name//[.:]/_}"

  if ! tmux has-session -t="$session_name" 2>/dev/null; then
    tmux new-session -ds "$session_name" -c "$selected"
  fi

  if [[ -z "$TMUX" ]]; then
    tmux attach-session -t "$session_name"
  else
    tmux switch-client -t "$session_name"
  fi
}
