#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Function to print a formatted message.
msg() {
  echo "› › › $1"
}

# --- Setup Functions ---

# Checks if GNU Stow is installed and provides installation instructions if it is not.
check_dependencies() {
  msg "Checking for dependencies..."
  if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed." >&2
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "Please install it with: brew install stow" >&2
    else
        echo "Please install it with your package manager (e.g., sudo apt-get install stow)" >&2
    fi
    exit 1
  fi
  msg "All dependencies are installed."
}

# Stow directories to their respective locations in the home directory.
stow_directories() {
    msg "Stowing directories..."
    # Stow zsh config to $HOME
    stow zsh

    # Stow other configs to their specific targets
    stow .config -t "$HOME/.config"
    stow .ssh -t "$HOME/.ssh"
    msg "Stowing complete."
}

# Create symbolic links for individual configuration files in the home directory.
link_config_files() {
    msg "Linking individual configuration files..."
    local dotfiles_dir
    dotfiles_dir=$(pwd)

    # Ensure the target directory for .gemini settings exists
    mkdir -p "$HOME/.gemini"

    ln -sfv "$dotfiles_dir/.gitconfig" "$HOME/.gitconfig"
    ln -sfv "$dotfiles_dir/.aider.conf.yml" "$HOME/.aider.conf.yml"
    ln -sfv "$dotfiles_dir/.shell-integration.zsh" "$HOME/.shell-integration.zsh"
    ln -sfv "$dotfiles_dir/.p10k.zsh" "$HOME/.p10k.zsh"
    ln -sfv "$dotfiles_dir/.gemini/settings.json" "$HOME/.gemini/settings.json"

    msg "Linking complete."
}


# --- Main Execution ---

main() {
    msg "Starting dotfiles setup..."
    check_dependencies
    stow_directories
    link_config_files
    echo
    msg "✅ Setup complete!"
}

# Run the main function
main