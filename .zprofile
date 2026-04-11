export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
export SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock
export XDG_CONFIG_HOME="$HOME/.config"

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(mise activate zsh --shims)"
