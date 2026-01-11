#!/usr/bin/env bash
# Full bootstrap script for new Mac setup
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"

echo "=== Mac Bootstrap Script ==="

# 1. Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed"
fi

# 2. Clone dotfiles if not present
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Installing GitHub CLI and cloning dotfiles..."
    brew install gh
    gh auth login
    gh repo clone mapringg/.dotfiles "$DOTFILES_DIR"
else
    echo "Dotfiles already cloned"
fi

# 3. Install packages via Brewfile
echo "Installing packages from Brewfile..."
cd "$DOTFILES_DIR"
brew bundle

# 4. Symlink dotfiles with Stow
echo "Symlinking dotfiles..."
stow --no-folding .

# 5. Configure macOS defaults
echo "Configuring macOS defaults..."
"$DOTFILES_DIR/scripts/osx-defaults.sh"

# 6. Setup Fish plugins
echo "Setting up Fish plugins..."
fish -c "fisher install jorgebucaran/hydro"

# 7. Setup development tools
echo "Setting up development tools..."
cd "$DOTFILES_DIR"
mise trust
mise install

# 8. Create Developer directory
mkdir -p "$HOME/Developer"

echo ""
echo "=== Bootstrap complete! ==="
echo "Restart your terminal or run: exec fish"
