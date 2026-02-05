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
    local out key line ref

    command -v fzf >/dev/null 2>&1 || return
    git rev-parse --git-dir >/dev/null 2>&1 || return

    while true; do
        out="$(git log --oneline --decorate -n 500 2>/dev/null | fzf --reverse --prompt='diff> ' --header='enter:commit  alt-enter:commit..HEAD  alt-s:stacked commit..HEAD' --expect=alt-enter,alt-s)" || break

        if [[ "$out" == *$'\n'* ]]; then
            key="${out%%$'\n'*}"
            line="${out#*$'\n'}"
        else
            key=''
            line="$out"
        fi

        ref="${line%% *}"
        [[ -n "$ref" ]] || continue

        if [[ "$key" == alt-enter ]]; then
            lumen diff "$ref..HEAD"
            continue
        fi

        if [[ "$key" == alt-s ]]; then
            lumen diff --stacked "$ref..HEAD"
            continue
        fi

        lumen diff "$ref"
    done
}

lec() {
    local end out key line ref

    command -v fzf >/dev/null 2>&1 || return
    git rev-parse --git-dir >/dev/null 2>&1 || return

    end="${1:-HEAD}"

    out="$(git log --oneline --decorate -n 500 2>/dev/null | fzf --reverse --prompt='explain> ' --header='enter:commit  alt-enter:commit..END' --expect=alt-enter)" || return

    if [[ "$out" == *$'\n'* ]]; then
        key="${out%%$'\n'*}"
        line="${out#*$'\n'}"
    else
        key=''
        line="$out"
    fi

    ref="${line%% *}"
    [[ -n "$ref" ]] || return

    if [[ "$key" == alt-enter ]]; then
        lumen explain "$ref..$end"
        return
    fi

    lumen explain "$ref"
}
