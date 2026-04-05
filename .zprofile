export XDG_CONFIG_HOME="$HOME/.config"

if [[ "$OSTYPE" == darwin* ]] && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

typeset -U path
path=("$HOME/.local/bin" $path)

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi
