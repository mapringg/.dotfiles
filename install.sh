#!/usr/bin/env bash

create_symlink() {
  local source_path=$1
  local target_path=$2

  # Ensure the parent directory of the target exists
  mkdir -p "$(dirname "$target_path")"

  # Handle existing files or symlinks at the target path
  if [ -L "$target_path" ]; then
    # If it's a symlink, remove it
    echo "Removing existing symlink: $target_path"
    rm "$target_path"
  elif [ -e "$target_path" ]; then
    # If it's any other file/directory, ask for confirmation
    echo "File exists: $target_path"
    if [ -e "$target_path.bak" ]; then
      echo "WARNING: Backup file $target_path.bak already exists and will be overwritten."
    fi
    read -p "Overwrite $target_path? (y/N): " -r
    if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
      echo "Skipping $target_path"
      return
    fi
    echo "Backing up $target_path to $target_path.bak"
    mv "$target_path" "$target_path.bak"
  fi

  # Create the new symlink
  ln -nsf "$source_path" "$target_path"
  echo "Linked $source_path to $target_path"
}

# Get the absolute path of the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Array of paths to link.
# Format: "source_path:target_path"
links=(
  ".codex:.codex"
  ".config/ghostty:.config/ghostty"
  ".config/git:.config/git"
  ".config/mise:.config/mise"
  ".config/nvim:.config/nvim"
  ".config/opencode:.config/opencode"
  ".config/starship.toml:.config/starship.toml"
  ".ssh/config:.ssh/config"
  ".zprofile:.zprofile"
  ".zshrc:.zshrc"
  ".tmux.conf:.tmux.conf"
)

# Check for configs that would create new .bak files
echo "Checking for existing files..."
configs_found=false
for link in "${links[@]}"; do
  target="${link#*:}"
  target_path="$HOME/$target"
  
  # Only warn if the target exists and is not a symlink
  if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
    echo "Found existing file: $target_path"
    configs_found=true
  fi
done

if [ "$configs_found" = true ]; then
  echo ""
  echo "Some existing files were found. You will be prompted individually for each file."
  echo ""
fi

# Detect OS
OS="$(uname)"

# Define OS-specific files to skip on Linux
linux_skips=".zprofile .zshrc .config/ghostty"

for link in "${links[@]}"; do
  source="${link%:*}"
  target="${link#*:}"

  # Check for and apply OS-specific skips on Linux
  if [ "$OS" = "Linux" ]; then
    skip_this=false
    for skip_item in $linux_skips; do
      if [ "$source" = "$skip_item" ]; then
        echo "Skipping $source on Linux."
        skip_this=true
        break
      fi
    done
    if [ "$skip_this" = true ]; then
      continue
    fi
  fi

  create_symlink "$DOTFILES_DIR/$source" "$HOME/$target"
done

echo "Dotfiles setup complete."
