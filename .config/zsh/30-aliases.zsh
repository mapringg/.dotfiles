alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias a='amp'
alias d='docker'
alias fd='fd --hidden --ignore-case'
alias l='lazygit'
alias le='lumen explain'
alias les='lumen explain --staged'
alias n='nvim'
alias o='opencode'

if command -v brew >/dev/null 2>&1; then
    alias up='brew update && brew upgrade && mise up'
elif command -v yay >/dev/null 2>&1; then
    alias up='yay -Syu && mise up'
fi

if command -v eza >/dev/null 2>&1; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
fi
