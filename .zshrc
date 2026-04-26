if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR=vi
export PATH="$HOME/.local/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
export BAT_THEME=ansi

for brewpath in /opt/homebrew /home/linuxbrew/.linuxbrew; do
  [[ -x "$brewpath/bin/brew" ]] && eval "$("$brewpath/bin/brew" shellenv)" && break
done

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit
compinit -C

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt sharehistory

alias ls='eza'
alias la='eza -a'
alias ll='eza -la'
alias lt='eza -T'
alias lta='eza -laT'
alias cat='bat'

alias gl='git log --graph --pretty=format:"%C(auto)%h%d %s %C(dim white)%C(bold)%cr"'
alias gla='git log --graph --pretty=format:"%C(auto)%h%d %s %C(dim white)%C(bold)%cr" --all'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias grst='git restore --staged'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gp='git push'
alias gpl='git pull'
alias gcb='git checkout -b'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gfa='git fixup --autosquash HEAD~'
alias gwho='git blame'
alias gsh='git show'
alias gcp='git cherry-pick'

source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"

eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
