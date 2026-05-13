if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="vi"
export VISUAL="code --wait"
export PATH="$HOME/.local/bin:$PATH"

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt sharehistory

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit
compinit -C

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

if (( $+commands[keychain] )) && [[ -f ~/.ssh/id_ed25519 ]]; then
  eval "$(keychain --eval --quiet id_ed25519)"
fi

source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"

eval "$(zoxide init zsh)"
eval "$(command wt config shell init zsh)"

alias a="wt switch -c -x amp -b @"
alias c="wt switch -c -x claude -b @"
alias l="lazygit"
alias p="gh pr create --fill-first --base"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if (( $+commands[wslpath] )); then
  keep_current_path() {
    printf '\e]9;9;%s\e\\' "$(wslpath -w "$PWD")"
  }
  precmd_functions+=(keep_current_path)
fi

