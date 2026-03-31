export XDG_CONFIG_HOME="$HOME/.config"

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

typeset -U path
path=("$HOME/.local/bin" $path)
eval "$(mise activate zsh --shims)"
