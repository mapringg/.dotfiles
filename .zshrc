
source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"

[[ ! -f $HOME/.zsh_plugins.zsh || $HOME/.zsh_plugins.txt -nt $HOME/.zsh_plugins.zsh ]] \
  && antidote bundle <"$HOME/.zsh_plugins.txt" >"$HOME/.zsh_plugins.zsh"
source "$HOME/.zsh_plugins.zsh"

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

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

autoload -Uz compinit
compinit

source <(fzf --zsh)

eval "$(zoxide init zsh --cmd cd)"
