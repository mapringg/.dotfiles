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
    stow home

    # Stow other configs to their specific targets
    stow .config -t "$HOME/.config"
    stow .ssh -t "$HOME/.ssh"
    msg "Stowing complete."
}

# --- Main Execution ---

main() {
    msg "Starting dotfiles setup..."
    check_dependencies
    stow_directories
    echo
    msg "✅ Setup complete!"
}

# Run the main function
main