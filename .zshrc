[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh"

[[ $- != *i* ]] && return

typeset -U path
path=("$HOME/.local/bin" $path)

if command -v brew >/dev/null 2>&1; then
  local antidote_path="$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
  [[ -f "$antidote_path" ]] && source "$antidote_path"
fi

if command -v antidote >/dev/null 2>&1; then
  [[ -f $HOME/.zsh_plugins.zsh ]] && source "$HOME/.zsh_plugins.zsh"
fi

export BAT_THEME=ansi
export EDITOR=nvim
export HOMEBREW_NO_ENV_HINTS=1
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export XDG_CONFIG_HOME="$HOME/.config"

export FZF_CTRL_T_COMMAND="fd --type f --hidden --strip-cwd-prefix"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --strip-cwd-prefix"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

export SUDO_EDITOR="$EDITOR"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias a='amp'
alias cc='claude'
alias c='codex --full-auto'
alias g='gemini --yolo'
alias l='lazygit'
alias lu='lumen'

if command -v mise >/dev/null 2>&1; then
  alias up='brew update && brew upgrade && mise up'
else
  alias up='brew update && brew upgrade'
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

b() {
  command -v fd >/dev/null 2>&1 || return

  fd --hidden --type l \
    . ~ \
    --exec sh -c 'test ! -e "$1" && echo "$1"' _ {}
}

n() {
  if [[ "$#" -eq 0 ]]; then
    nvim .
  else
    nvim "$@"
  fi
}

bindkey -e

HISTSIZE=5000
SAVEHIST=$HISTSIZE

setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt sharehistory

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

[[ -f $HOME/.env ]] && source "$HOME/.env"

[[ -f $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"
