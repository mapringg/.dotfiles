# File system
if command -q eza
    alias ls 'eza -lh --group-directories-first --icons=auto'
    alias lsa 'ls -a'
    alias lt 'eza --tree --level=2 --long --icons --git'
    alias lta 'lt -a'
end

alias ff "fzf --preview 'bat --style=numbers --color=always {}'"
alias cat bat

# zoxide cd wrapper
if command -q zoxide
    alias cd zd
end

# Directories
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
