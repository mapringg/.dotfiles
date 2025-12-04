if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export EDITOR=nvim
export ZSH_PLUGINS_ALIAS_TIPS_TEXT="💡 Alias tip: "
export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDE='(_|ll|la|ls)'

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1; zinit light romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
    Aloxaf/fzf-tab \
    zdharma-continuum/fast-syntax-highlighting \
    djui/alias-tips

zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^p' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
zle_highlight+=(paste:none)

HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_verify
setopt hist_expire_dups_first
setopt extended_glob

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'

(( $+commands[nvim] )) && alias vim='nvim'
(( $+commands[lazygit] )) && alias lg='lazygit'

if (( $+commands[eza] )); then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
  alias tree='eza --tree'
fi

(( $+commands[bat] )) && alias cat='bat --paging=never'

alias oc='opencode'
alias cl='claude'
alias ge='gemini'

(( $+commands[fzf] )) && eval "$(fzf --zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"
typeset -U path

function ghelp() {
    echo "\033[1;36mEssential Git Aliases\033[0m"
    echo ""
    echo "  \033[1;33mgst\033[0m    git status"
    echo "  \033[1;33mgaa\033[0m    git add --all"
    echo "  \033[1;33mgcmsg\033[0m  git commit -m"
    echo "  \033[1;33mgp\033[0m     git push"
    echo "  \033[1;33mgl\033[0m     git pull"
    echo "  \033[1;33mgd\033[0m     git diff"
    echo "  \033[1;33mgds\033[0m    git diff --staged"
    echo "  \033[1;33mglog\033[0m   git log --oneline --graph --decorate"
    echo ""
    echo "  \033[1;35mBranching\033[0m"
    echo "  \033[1;33mgco\033[0m    git checkout"
    echo "  \033[1;33mgcb\033[0m    git checkout -b"
    echo "  \033[1;33mgb\033[0m     git branch"
    echo "  \033[1;33mgm\033[0m     git merge"
    echo ""
    echo "  \033[1;35mAdvanced\033[0m"
    echo "  \033[1;33mgrb\033[0m    git rebase"
    echo "  \033[1;33mgrbi\033[0m   git rebase -i (interactive)"
    echo "  \033[1;33mgsta\033[0m   git stash push"
    echo "  \033[1;33mgstp\033[0m   git stash pop"
    echo ""
}

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
