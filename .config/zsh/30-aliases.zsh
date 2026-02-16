alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias a='amp'
alias c='claude --dangerously-skip-permissions'
alias co='codex --dangerously-bypass-approvals-and-sandbox'
alias d='docker'
alias fd='fd --hidden --ignore-case'
alias g='gemini --yolo'
alias l='lazygit'

if command -v brew >/dev/null 2>&1; then
  if command -v mise >/dev/null 2>&1; then
    alias up='brew update && brew upgrade && mise up'
  else
    alias up='brew update && brew upgrade'
  fi
elif command -v yay >/dev/null 2>&1; then
  if command -v mise >/dev/null 2>&1; then
    alias up='yay -Syu && mise up'
  else
    alias up='yay -Syu'
  fi
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi
