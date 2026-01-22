[[ $- != *i* ]] && return

OS="$(uname -s)"

if [[ -f ~/.local/share/omarchy/default/bash/rc ]]; then
    source ~/.local/share/omarchy/default/bash/rc

elif [[ "$OS" == "Darwin" ]]; then

    # Homebrew
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Shell
    shopt -s histappend
    HISTCONTROL=ignoreboth
    HISTSIZE=32768
    HISTFILESIZE="${HISTSIZE}"
    set +h

    # Environment
    export EDITOR="vim"
    export SUDO_EDITOR="$EDITOR"
    export BAT_THEME=ansi
    export HOMEBREW_NO_ENV_HINTS=1

    # Aliases
    if command -v eza &> /dev/null; then
        alias ls='eza -lh --group-directories-first --icons=auto'
        alias lsa='ls -a'
        alias lt='eza --tree --level=2 --long --icons --git'
        alias lta='lt -a'
    fi

    alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

    if command -v zoxide &> /dev/null; then
        alias cd="zd"
        zd() {
            if [ $# -eq 0 ]; then
                builtin cd ~ && return
            elif [ -d "$1" ]; then
                builtin cd "$1"
            else
                z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
            fi
        }
    fi

    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'

    alias c='opencode'
    alias d='docker'
    alias r='rails'
    n() { if [ "$#" -eq 0 ]; then vim .; else vim "$@"; fi; }

    # Tool init
    if command -v mise &> /dev/null; then
        eval "$(mise activate bash)"
    fi

    if command -v starship &> /dev/null; then
        eval "$(starship init bash)"
    fi

    if command -v zoxide &> /dev/null; then
        eval "$(zoxide init bash)"
    fi

    if command -v fzf &> /dev/null; then
        if [[ -f /opt/homebrew/opt/fzf/shell/completion.bash ]]; then
            source /opt/homebrew/opt/fzf/shell/completion.bash
        fi
        if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]]; then
            source /opt/homebrew/opt/fzf/shell/key-bindings.bash
        fi
    fi
fi

# Personal
export PATH="$HOME/.local/bin:$PATH"
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
alias fd='fd --hidden --ignore-case'
