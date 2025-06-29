#!/bin/bash

# Dotfiles setup script

# Detect OS
if [[ "$(uname)" == "Darwin" ]]; then
    OS="macos"
else
    OS="linux"
fi

echo "Detected OS: $OS"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is not installed."
    if [[ "$OS" == "macos" ]]; then
        echo "Please install it with: brew install stow"
    else
        echo "Please install it with: sudo apt-get install stow"
    fi
    exit 1
fi

# Setup for Linux
if [[ "$OS" == "linux" ]]; then
    echo "Setting up for Linux..."
    
    # Check if .bashrc.local is already sourced in .bashrc
    if ! grep -q "source ~/.bashrc.local" ~/.bashrc; then
        echo "Adding source line to .bashrc..."
        echo -e "
# Source local bashrc if it exists
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi" >> ~/.bashrc
    else
        echo ".bashrc already configured."
    fi
    
    # Check if .profile.local is already sourced in .profile
    if ! grep -q "source ~/.profile.local" ~/.profile; then
        echo "Adding source line to .profile..."
        echo -e "
# Source local profile if it exists
if [ -f ~/.profile.local ]; then
    source ~/.profile.local
fi" >> ~/.profile
    else
        echo ".profile already configured."
    fi
    
    # Stow bash configuration
    echo "Stowing bash configuration..."
    stow bash
fi

# Setup for macOS
if [[ "$OS" == "macos" ]]; then
    echo "Setting up for macOS..."
    
    # Stow zsh configuration
    echo "Stowing zsh configuration..."
    stow zsh
fi

# Stow common configurations
echo "Stowing common configurations..."
# stow bin -t $HOME/.local/bin
stow .config -t $HOME/.config
stow .ssh -t $HOME/.ssh

# Copy individual files directly
echo "Copying individual configuration files..."
ln -sf "$(pwd)/.gitconfig" $HOME/.gitconfig
ln -sf "$(pwd)/.aider.conf.yml" $HOME/.aider.conf.yml
ln -sf "$(pwd)/.shell-integration.zsh" $HOME/.shell-integration.zsh

echo "Setup complete!"
