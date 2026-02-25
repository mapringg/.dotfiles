alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias a='amp'
alias c='claude --dangerously-skip-permissions'
alias co='codex --dangerously-bypass-approvals-and-sandbox'
alias d='docker'
alias fd='fd --hidden --ignore-case'
alias ge='gemini --yolo'
alias l='lazygit'

if command -v mise >/dev/null 2>&1; then
  alias up='brew update && brew upgrade && mise up'
else
  alias up='brew update && brew upgrade'
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi
