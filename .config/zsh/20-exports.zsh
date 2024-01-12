export BAT_THEME=ansi
export EDITOR=nvim
export HOMEBREW_NO_ENV_HINTS=1
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
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
