# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
if [ -f ~/.local/bin/mise ]; then
    eval "$(mise activate bash --shims)"
fi
