# Alias FZF selection
function alias-fzf() {
  local selected_alias
  selected_alias=$(alias | fzf)

  if [[ -n "$selected_alias" ]]; then
    # Extract the alias name (e.g., "ll" from "ll='ls -l'")
    local alias_name=$(echo "$selected_alias" | awk -F'=' '{print $1}')

    # Execute the alias
    eval "$alias_name"

    # Do nothing if no alias was selected
    zle reset-prompt  # Reset the prompt without creating a new line
  fi
}
zle -N alias-fzf
bindkey '^g' alias-fzf
