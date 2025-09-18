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

# Array of paths to link.
# Format: "source_path:target_path"
links=(
  ".claude:.claude"
  ".codex:.codex"
  ".config/ghostty:.config/ghostty"
  ".config/git:.config/git"
  ".config/mise:.config/mise"
  ".config/nvim:.config/nvim"
  ".config/starship.toml:.config/starship.toml"
  ".gemini:.gemini"
  ".ssh/config:.ssh/config"
  ".zprofile:.zprofile"
  ".zshrc:.zshrc"
  ".tmux.conf:.tmux.conf"
)

# Check for existing .bak files before proceeding
echo "Checking for existing backup files..."
backup_files_found=false
for link in "${links[@]}"; do
  target="${link#*:}"
  backup_path="$HOME/$target.bak"
  if [ -e "$backup_path" ]; then
    echo "Found existing backup: $backup_path"
    backup_files_found=true
  fi
done

if [ "$backup_files_found" = true ]; then
  echo ""
  echo "WARNING: Existing backup files (.bak) were found!"
  echo "Running this script again will overwrite these backups."
  echo "Please review and handle these backup files before proceeding."
  echo ""
  echo "Options:"
  echo "1. Remove backup files if they're no longer needed"
  echo "2. Move them to a different location"
  echo "3. Cancel this installation"
  echo ""
  read -p "Do you want to continue anyway? (y/N): " -r
  if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
    echo "Installation cancelled."
    exit 1
  fi
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
