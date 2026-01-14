set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden'
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -x FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always {}'"
set -x FZF_ALT_C_COMMAND 'fd --type d --hidden'
set -x FZF_ALT_C_OPTS "--preview 'eza --tree --level=2 --icons {}'"

set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

fzf --fish | source
