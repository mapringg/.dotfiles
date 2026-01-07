# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source all modular bash configs
source ~/.config/bash/shell
source ~/.config/bash/aliases
source ~/.config/bash/functions
source ~/.config/bash/prompt
source ~/.config/bash/init
source ~/.config/bash/envs

# Add your own exports, aliases, and functions below
[[ -f ~/.config/bash/envs.local ]] && source ~/.config/bash/envs.local
