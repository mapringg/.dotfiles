#!/bin/bash

create_symlink() {
  local source_path=$1
  local target_path=$2

  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ]; then
    rm "$target_path"
  elif [ -e "$target_path" ]; then
    mv "$target_path" "$target_path.bak"
  fi

  ln -nsf "$source_path" "$target_path"
  echo "Linked $source_path to $target_path"
}

link_directory_contents() {
  local source_dir=$1
  local target_dir=$2
  source_dir=${source_dir%/}

  find "$source_dir" -type f | while read -r file; do
    relative_path=${file#$source_dir/}
    target_path="$target_dir/$relative_path"
    create_symlink "$file" "$target_path"
  done
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Detect OS
OS="$(uname)"

# Root-level dotfiles (skip bash-related on Linux)
if [ "$OS" = "Darwin" ]; then
  [ -f "$DOTFILES_DIR/.bashrc" ] && create_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
fi
[ -f "$DOTFILES_DIR/.gitconfig" ] && create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# .config directory
if [ -d "$DOTFILES_DIR/.config" ]; then
  if [ "$OS" = "Darwin" ]; then
    # macOS: link all directories
    for dir in "$DOTFILES_DIR/.config"/*; do
      [ -d "$dir" ] && link_directory_contents "$dir" "$HOME/.config/$(basename "$dir")"
    done
  else
    # Linux: only link mise
    [ -d "$DOTFILES_DIR/.config/mise" ] && link_directory_contents "$DOTFILES_DIR/.config/mise" "$HOME/.config/mise"
  fi
fi

# .ssh directory
if [ -d "$DOTFILES_DIR/.ssh" ]; then
  for file in "$DOTFILES_DIR/.ssh"/*; do
    [ -f "$file" ] && create_symlink "$file" "$HOME/.ssh/$(basename "$file")"
  done
fi

# claude and gemini directories
[ -d "$DOTFILES_DIR/claude" ] && link_directory_contents "$DOTFILES_DIR/claude" "$HOME/.claude"
[ -d "$DOTFILES_DIR/gemini" ] && link_directory_contents "$DOTFILES_DIR/gemini" "$HOME/.gemini"

echo "Dotfiles setup complete."
