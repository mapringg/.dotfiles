[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

[[ $- != *i* ]] && return

path=("$HOME/.local/bin" $path)

for f in /opt/homebrew/opt/antidote/share/antidote/antidote.zsh /usr/share/zsh-antidote/antidote.zsh; do
    [[ -f $f ]] && source $f
done
if command -v antidote >/dev/null 2>&1; then
    [[ -f $HOME/.zsh_plugins.zsh ]] && source "$HOME/.zsh_plugins.zsh"
fi

export BAT_THEME=ansi
export EDITOR=nvim
export HOMEBREW_NO_ENV_HINTS=1
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
export SUDO_EDITOR="$EDITOR"
export XDG_CONFIG_HOME="$HOME/.config"

export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
export FZF_CTRL_T_COMMAND="fd --type f --hidden --strip-cwd-prefix"
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {}'"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --strip-cwd-prefix"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias a='amp'
alias d='docker'
alias fd='fd --hidden --ignore-case'
alias l='lazygit'
alias o='opencode'

if command -v eza >/dev/null 2>&1; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
fi

ff() {
    fzf --preview 'bat --style=numbers --color=always {}' "$@" || true
}

fzf-git-branch() {
    git rev-parse HEAD > /dev/null 2>&1 || return
    local branch=$(git branch --color=always --all --sort=-committerdate | grep -v HEAD | fzf --ansi --no-multi --preview 'git log -n 50 --color=always --date=short --pretty=format:"%C(auto)%cd %h%d %s" $(sed "s/^[* ]*//" <<<{})' | sed "s/^[* ]*//")
    [[ -n "$branch" ]] && git checkout "$branch"
    return 0
}

fzf-git-log() {
    git rev-parse HEAD > /dev/null 2>&1 || return
    local commit=$(git log --color=always --oneline --no-decorate -50 | fzf --ansi --no-multi --preview 'git show --color=always {1}' | cut -d' ' -f1)
    [[ -n "$commit" ]] && git show "$commit"
    return 0
}

h() {
    if [[ -n "$API_COOKIE" ]]; then
        http "$@" Cookie:"$API_COOKIE"
    elif [[ -n "$API_TOKEN" ]]; then
        http "$@" Authorization:"Bearer $API_TOKEN"
    else
        echo "Set API_TOKEN or API_COOKIE in .env"
    fi
}

n() {
    if [[ $# -eq 0 ]]; then
        nvim .
    else
        nvim "$@"
    fi
}

bindkey -e
bindkey -s '\eG' $'\C-ufzf-git-log\n'
bindkey -s '\eg' $'\C-ufzf-git-branch\n'
bindkey -s '^g' $'tmux-sessionizer\n'

HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE

setopt appendhistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt sharehistory

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

autoload -Uz compinit
compinit

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

[[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
[[ -f $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"
