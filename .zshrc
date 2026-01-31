[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

[[ $- != *i* ]] && return

path=("$HOME/.local/bin" $path)

export EDITOR=nvim
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi
export HOMEBREW_NO_ENV_HINTS=1
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias fd='fd --hidden --ignore-case'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias a='amp'
alias d='docker'
alias l='lazygit'
alias o='opencode'

n() {
  if [[ $# -eq 0 ]]; then
    nvim .
  else
    nvim "$@"
  fi
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

bindkey -e
bindkey -s '^g' $'tmux-sessionizer\n'

HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTFILE=$HOME/.zsh_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

autoload -Uz compinit
compinit

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v fzf >/dev/null 2>&1; then
  for f in /opt/homebrew/opt/fzf/shell/completion.zsh /usr/share/fzf/completion.zsh; do
    [[ -f $f ]] && source $f
  done
  for f in /opt/homebrew/opt/fzf/shell/key-bindings.zsh /usr/share/fzf/key-bindings.zsh; do
    [[ -f $f ]] && source $f
  done
fi

for f in /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -f $f ]] && source $f
done

for f in /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme; do
  [[ -f $f ]] && source $f
done

for f in /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -f $f ]] && source $f
done

[[ -f $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"
