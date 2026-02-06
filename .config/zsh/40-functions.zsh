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

lc() {
    local msg

    if (( $# )); then
        msg="$(lumen draft -c "$*")" || return
    else
        msg="$(lumen draft)" || return
    fi

    print -r -- "$msg" | git commit -F -
}

ld() {
    if (( $# == 0 )); then
        lumen diff -w
        return
    fi

    lumen diff "$@"
}

ldc() {
    local end out key line ref

    command -v fzf >/dev/null 2>&1 || return
    git rev-parse --git-dir >/dev/null 2>&1 || return

    while true; do
        out="$(git log --oneline --decorate -n 500 2>/dev/null | fzf --reverse --prompt='diff> ' --header='enter:commit  tab:commit..ref  alt-s:stacked commit..ref' --expect=tab,alt-s)" || break

        if [[ "$out" == *$'\n'* ]]; then
            key="${out%%$'\n'*}"
            line="${out#*$'\n'}"
        else
            key=''
            line="$out"
        fi

        ref="${line%% *}"
        [[ -n "$ref" ]] || continue

        if [[ "$key" == tab ]]; then
            end="$(git log --oneline --decorate -n 500 2>/dev/null | fzf --reverse --prompt='end> ')" || continue
            end="${end%% *}"
            [[ -n "$end" ]] || continue
            lumen diff "$ref^..$end"
            continue
        fi

        if [[ "$key" == alt-s ]]; then
            end="$(git log --oneline --decorate -n 500 2>/dev/null | fzf --reverse --prompt='end> ')" || continue
            end="${end%% *}"
            [[ -n "$end" ]] || continue
            lumen diff --stacked "$ref^..$end"
            continue
        fi

        lumen diff "$ref"
    done
}

lec() {
    local end out key line ref

    command -v fzf >/dev/null 2>&1 || return
    git rev-parse --git-dir >/dev/null 2>&1 || return

    out="$(git log --oneline --decorate -n 500 2>/dev/null | fzf --reverse --prompt='explain> ' --header='enter:commit  tab:commit..ref' --expect=tab)" || return

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
        lumen explain "$ref^..$end"
        return
    fi

    lumen explain "$ref"
}
