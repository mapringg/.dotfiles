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

fk() {
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

fb() {
  local branch

  command -v fzf >/dev/null 2>&1 || return
  git rev-parse --git-dir >/dev/null 2>&1 || return

  branch="$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads refs/remotes | grep -v '^origin/HEAD$' | sed 's#^origin/##' | awk '!seen[$0]++' | fzf --reverse --prompt='checkout> ')" || return
  [[ -n "$branch" ]] || return
  git checkout "$branch"
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
    command -v fd >/dev/null 2>&1 || return
    command -v fzf >/dev/null 2>&1 || return

    all_dirs=$(
      fd --type d --hidden --no-ignore --glob '.git' --max-depth 3 "${SEARCH_DIRS[@]}" 2>/dev/null |
        sed "s|/.git/$||; s|^$HOME/||; s|^code/||" |
        sort
    )

    local original_session
    [[ -n "$TMUX" ]] && original_session=$(tmux display-message -p '#{session_name}')

    while true; do
      local fzf_out fzf_key
      existing_sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)

      local -a fzf_opts=(--cycle --expect=tab --header='tab: kill session' --no-sort)
      if [[ -n "$TMUX" ]]; then
        fzf_opts+=(--bind "focus:execute-silent(echo {} | grep -q '^● ' && tmux switch-client -t \"\$(echo {} | sed 's/^● //')\" 2>/dev/null || tmux switch-client -t '$original_session' 2>/dev/null)")
      fi

      fzf_out=$(
        {
          if [[ -n "$existing_sessions" ]]; then
            if [[ -n "$original_session" ]]; then
              echo "● $original_session"
              grep -v "^${original_session}$" <<< "$existing_sessions" | grep -v '^$' | sed 's/^/● /'
            else
              sed 's/^/● /' <<< "$existing_sessions"
            fi
          fi
          if [[ -n "$existing_sessions" ]]; then
            local sessions_as_keys=$(echo "$existing_sessions" | paste -sd'|' -)
            echo "$all_dirs" | awk -v keys="$sessions_as_keys" '
              BEGIN { n=split(keys, a, "|"); for(i=1;i<=n;i++) { gsub(/[.:]/, "_", a[i]); seen[a[i]]=1 } }
              { k=$0; gsub(/[.:]/, "_", k); if(!seen[k]) print }
            '
          else
            echo "$all_dirs"
          fi
        } |
          fzf "${fzf_opts[@]}"
      ) || {
        [[ -n "$original_session" ]] && tmux switch-client -t "$original_session" 2>/dev/null
        return
      }

      fzf_key=$(head -1 <<< "$fzf_out")
      selected=$(tail -1 <<< "$fzf_out")

      if [[ "$fzf_key" == "tab" ]]; then
        if [[ "$selected" == "● "* ]]; then
          local kill_target="${selected#● }"
          tmux kill-session -t "$kill_target" 2>/dev/null
          [[ "$kill_target" == "$original_session" ]] && original_session=""
        fi
        continue
      fi

      break
    done

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
