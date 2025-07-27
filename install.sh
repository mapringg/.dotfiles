#!/bin/bash
#
# This script creates symbolic links for all configurations in the dotfiles repository.
# It detects the operating system and links the appropriate platform-specific files.

# --- Helper Functions ---

# Creates a symbolic link, backing up the original file if it exists.
create_symlink() {
  local source_path=$1
  local target_path=$2

  # Create the target directory if it doesn't exist
  mkdir -p "$(dirname "$target_path")"

  # If the target is a symlink, remove it
  if [ -L "$target_path" ]; then
    rm "$target_path"
  # If the target is a file or directory, back it up
  elif [ -e "$target_path" ]; then
    mv "$target_path" "$target_path.bak"
  fi

  ln -nsf "$source_path" "$target_path"
  echo "Linked $source_path to $target_path"
}

# Recursively links all files in a directory, maintaining structure
link_directory_contents() {
  local source_dir=$1
  local target_dir=$2

  # Remove trailing slash from source_dir if present
  source_dir=${source_dir%/}

  # Find all files in the source directory
  find "$source_dir" -type f | while read -r file; do
    # Get the relative path from the source directory
    relative_path=${file#$source_dir/}
    # Create the target path
    target_path="$target_dir/$relative_path"
    # Create the symlink
    create_symlink "$file" "$target_path"
  done
}

# --- Main Script ---

DOTFILES_DIR=~/.dotfiles

# --- Shared Configurations ---

echo "Setting up shared configurations..."
# Shared .config directories
for dir in $DOTFILES_DIR/.config/*/; do
  if [ -d "$dir" ]; then
    dirname=$(basename "$dir")
    link_directory_contents "$dir" "$HOME/.config/$dirname"
  fi
done

# Special cases for root-level files
create_symlink $DOTFILES_DIR/.gitconfig ~/.gitconfig
create_symlink $DOTFILES_DIR/.ssh/config ~/.ssh/config

# Link .claude and .gemini directories
if [ -d $DOTFILES_DIR/claude ]; then
  link_directory_contents $DOTFILES_DIR/claude ~/.claude
fi
if [ -d $DOTFILES_DIR/gemini ]; then
  link_directory_contents $DOTFILES_DIR/gemini ~/.gemini
fi

# --- Platform-Specific Configurations ---

OS=$(uname -s)
PLATFORM_DIR=""

if [ "$OS" == "Darwin" ]; then
  PLATFORM_DIR="apple"
elif [ "$OS" == "Linux" ]; then
  # Add more specific linux checks here if needed
  PLATFORM_DIR="archlinux"
else
  echo "Unsupported OS: $OS"
  exit 1
fi

echo "Setting up $PLATFORM_DIR configurations for $OS..."

# Link platform-specific dotfiles (hidden files)
for file in $DOTFILES_DIR/$PLATFORM_DIR/.*; do
  if [ -f "$file" ] && [ "$(basename "$file")" != "." ] && [ "$(basename "$file")" != ".." ]; then
    create_symlink "$file" ~/"$(basename "$file")"
  fi
done

# Link platform-specific .config directory
if [ -d $DOTFILES_DIR/$PLATFORM_DIR/.config ]; then
  link_directory_contents $DOTFILES_DIR/$PLATFORM_DIR/.config ~/.config
fi

echo "Dotfiles setup complete."
