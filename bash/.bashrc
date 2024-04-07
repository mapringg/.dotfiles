# .bashrc

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# User specific environment
[[ ! "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]] && export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        [ -f "$rc" ] && . "$rc"
    done
fi
unset rc

# brew
if command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# bat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# eza
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias la='eza -al'
    alias ll='eza -l'
fi

# fnm
if [ "$(uname)" == "Linux" ]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
fi
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd)"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
    source "$HOME/.bashrc.d/fzf.bash"
fi

# starship
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd bash)"
fi
