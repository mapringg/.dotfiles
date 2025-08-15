#!/usr/bin/env bash

create_symlink() {
  local source_path=$1
  local target_path=$2

  # Ensure the parent directory of the target exists
  mkdir -p "$(dirname "$target_path")"

  # Handle existing files or symlinks at the target path
  if [ -L "$target_path" ]; then
    # If it's a symlink, remove it
    rm "$target_path"
  elif [ -e "$target_path" ]; then
    # If it's any other file/directory, back it up
    mv "$target_path" "$target_path.bak"
  fi

  # Create the new symlink
  ln -nsf "$source_path" "$target_path"
  echo "Linked $source_path to $target_path"
}

# Get the absolute path of the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Associative array of paths to link.
# Key: Source path relative to this script's location.
# Value: Target path relative to the user's home directory.
declare -A links=(
  [".bashrc"]=".bashrc"
  [".gitconfig"]=".gitconfig"
  [".config/ghostty"]=".config/ghostty"
  [".config/mise"]=".config/mise"
  [".ssh/config"]=".ssh/config"
  ["claude"]=".claude"
  ["gemini"]=".gemini"
)

# Detect OS
OS="$(uname)"

# Define OS-specific files to skip. Use an associative array for easy lookups.
declare -A linux_skips=(
  [".bashrc"]=1
  [".config/ghostty"]=1
)

for source in "${!links[@]}"; do
  target="${links[$source]}"

  # Check for and apply OS-specific skips
  # Use -n to check if the key exists and has a non-empty value, for better bash compatibility.
  if [[ "$OS" == "Linux" && -n "${linux_skips[$source]}" ]]; then
    echo "Skipping $source on Linux."
    continue
  fi

  create_symlink "$DOTFILES_DIR/$source" "$HOME/$target"
done

echo "Dotfiles setup complete."
