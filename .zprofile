for brewpath in /opt/homebrew /home/linuxbrew/.linuxbrew; do
  if [[ -d "$brewpath" ]]; then
    export HOMEBREW_PREFIX="$brewpath"
    export HOMEBREW_CELLAR="$brewpath/Cellar"
    export HOMEBREW_REPOSITORY="$brewpath"
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
    export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
    break
  fi
done

export PATH="$HOME/.local/share/mise/shims:$PATH"
