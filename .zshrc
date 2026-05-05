if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=vi
export PATH="$HOME/.local/bin:$PATH"

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

if (( $+commands[keychain] )) && [[ -f ~/.ssh/id_ed25519 ]]; then
  eval "$(keychain --eval --quiet id_ed25519)"
fi

source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"

eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
