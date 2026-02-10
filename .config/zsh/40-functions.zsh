ar() {
    local end out key line ref

    command -v fzf >/dev/null 2>&1 || return
    git rev-parse --git-dir >/dev/null 2>&1 || return

    out="$(git log --oneline --decorate -n 500 2>/dev/null | fzf --reverse --prompt='review> ' --header='enter:commit  tab:commit..ref' --expect=tab)" || return

    if [[ "$out" == *$'\n'* ]]; then
        key="${out%%$'\n'*}"
        line="${out#*$'\n'}"
    else
        key=''
        line="$out"
    fi

    ref="${line%% *}"
    [[ -n "$ref" ]] || return

    if [[ "$key" == tab ]]; then
        end="$(git log --oneline --decorate -n 500 2>/dev/null | fzf --reverse --prompt='end> ')" || return
        end="${end%% *}"
        [[ -n "$end" ]] || return
        amp review "$ref^..$end"
        return
    fi

    amp review "$ref"
}
