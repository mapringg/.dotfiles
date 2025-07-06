#!/bin/bash
#
# This script creates symbolic links for all configurations in the dotfiles repository.
# It uses loops to automatically handle new files, so you don't have to manually
# add a new `ln` command for each new file.

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

# Shared configurations - handle nested directory structures
for dir in ~/.dotfiles/.config/*/; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        link_directory_contents "$dir" "$HOME/.config/$dirname"
    fi
done

# Arch Linux-specific dotfiles (hidden files starting with .)
for file in ~/.dotfiles/archlinux/.*; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "." ] && [ "$(basename "$file")" != ".." ]; then
        create_symlink "$file" ~/"$(basename "$file")"
    fi
done

# Arch Linux-specific .config directory
if [ -d ~/.dotfiles/archlinux/.config ]; then
    link_directory_contents ~/.dotfiles/archlinux/.config ~/.config
fi

# Special cases for root-level files
create_symlink ~/.dotfiles/.gitconfig ~/.gitconfig
create_symlink ~/.dotfiles/.ssh/config ~/.ssh/config
create_symlink ~/.dotfiles/.gemini/settings.json ~/.gemini/settings.json

echo "Dotfiles setup complete."
