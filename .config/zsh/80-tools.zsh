if command -v fzf >/dev/null 2>&1; then
    for f in /opt/homebrew/opt/fzf/shell/completion.zsh /usr/share/fzf/completion.zsh; do
        [[ -f $f ]] && source $f
    done

    for f in /opt/homebrew/opt/fzf/shell/key-bindings.zsh /usr/share/fzf/key-bindings.zsh; do
        [[ -f $f ]] && source $f
    done
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi
