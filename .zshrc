if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
typeset -U path

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
setopt autocd
setopt auto_pushd
setopt pushd_ignore_dups

bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^p' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
zle_highlight+=(paste:none)

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

(( $+commands[fzf] )) && eval "$(fzf --zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias rr='rm -rf'
alias sz='source ~/.zshrc'

(( $+commands[nvim] )) && alias vim='nvim'
(( $+commands[code] )) && alias c.='code .'
(( $+commands[lazygit] )) && alias lg='lazygit'
(( $+commands[opencode] )) && alias oc='opencode'
(( $+commands[claude] )) && alias cl='claude'
(( $+commands[gemini] )) && alias ge='gemini'

if (( $+commands[eza] )); then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
  alias tree='eza --tree'
fi

(( $+commands[bat] )) && alias cat='bat --paging=never'

if [[ "$OSTYPE" == "darwin"* ]]; then
  if (( $+commands[brew] )); then
    alias pz='brew uninstall --zap'
    alias pup='brew update && brew upgrade'
  fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias pup='sudo apt update && sudo apt upgrade'
  alias pz='sudo apt remove --purge'
fi

function ghelp() {
    echo "\033[1;36mGit Aliases\033[0m"
    echo ""
    echo "\033[1;35mDaily\033[0m"
    echo "  \033[1;33mgst\033[0m       git status"
    echo "  \033[1;33mgaa\033[0m       git add --all"
    echo "  \033[1;33mgcmsg\033[0m     git commit -m"
    echo "  \033[1;33mgp\033[0m        git push"
    echo "  \033[1;33mgl\033[0m        git pull"
    echo ""
    echo "\033[1;35mInspecting\033[0m"
    echo "  \033[1;33mgd\033[0m        git diff"
    echo "  \033[1;33mgds\033[0m       git diff --staged"
    echo "  \033[1;33mglog\033[0m      git log --oneline --graph"
    echo "  \033[1;33mgsh\033[0m       git show"
    echo ""
    echo "\033[1;35mStaging\033[0m"
    echo "  \033[1;33mgap\033[0m       git add --patch"
    echo "  \033[1;33mgrs\033[0m       git reset"
    echo ""
    echo "\033[1;35mBranching\033[0m"
    echo "  \033[1;33mgco\033[0m       git checkout"
    echo "  \033[1;33mgcb\033[0m       git checkout -b"
    echo "  \033[1;33mgb\033[0m        git branch"
    echo "  \033[1;33mgm\033[0m        git merge"
    echo ""
    echo "\033[1;35mAdvanced\033[0m"
    echo "  \033[1;33mgrbi\033[0m      git rebase -i"
    echo "  \033[1;33mgrb\033[0m       git rebase"
    echo "  \033[1;33mgsta\033[0m      git stash push"
    echo "  \033[1;33mgstp\033[0m      git stash pop"
    echo "  \033[1;33mgstl\033[0m      git stash list"
    echo "  \033[1;33mgsts\033[0m      git stash show"
    echo "  \033[1;33mgcp\033[0m       git cherry-pick"
    echo ""
}

function dhelp() {
    echo "\033[1;36mDevelopment & System Aliases\033[0m"
    echo ""
    echo "  \033[1;35mNavigation & System\033[0m"
    echo "  \033[1;33m..\033[0m     cd .."
    echo "  \033[1;33m...\033[0m    cd ../.."
    echo "  \033[1;33m....\033[0m   cd ../../.."
    echo "  \033[1;33mc\033[0m      clear"
    echo "  \033[1;33mrr\033[0m     rm -rf"
    echo "  \033[1;33msz\033[0m     source ~/.zshrc"
    echo ""
    echo "  \033[1;35mEditors & Tools\033[0m"
    echo "  \033[1;33mvim\033[0m    nvim"
    echo "  \033[1;33mc.\033[0m     code ."
    echo "  \033[1;33mlg\033[0m     lazygit"
    echo "  \033[1;33moc\033[0m     opencode"
    echo "  \033[1;33mcl\033[0m     claude"
    echo "  \033[1;33mge\033[0m     gemini"
    echo ""
    echo "  \033[1;35mMaintenance\033[0m"
    echo "  \033[1;33mpz\033[0m     package uninstall"
    echo "  \033[1;33mpup\033[0m    package update & upgrade"
    echo ""
}

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
