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
