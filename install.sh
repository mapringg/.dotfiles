#!/bin/bash

set -e

echo "Installing dotfiles..."

# Remove any existing broken symlinks
find ~ -maxdepth 2 -type l ! -exec test -e {} \; -delete 2>/dev/null || true

# Stow packages
echo "Linking shell configs..."
stow shell

echo "Linking app configs..."
stow xdg

echo "Dotfiles installed successfully!"