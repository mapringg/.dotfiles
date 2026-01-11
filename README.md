# Mac Setup Guide

This documents the steps to set up this Mac.

## Quick Setup (Automated)

For a fresh Mac, run the bootstrap script after cloning:

```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Clone and bootstrap
brew install gh
gh auth login
gh repo clone .dotfiles
cd ~/.dotfiles
./scripts/bootstrap.sh
```

## Manual Setup (Step by Step)

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

### 2. Install GitHub CLI & Clone Dotfiles

```bash
brew install gh
gh auth login
gh repo clone .dotfiles
```

### 3. Install Packages via Brewfile

```bash
cd ~/.dotfiles
brew bundle
```

### 4. Symlink Dotfiles with Stow

```bash
cd ~/.dotfiles
stow --no-folding .
```

### 5. Fish Shell Setup

```bash
fisher install jorgebucaran/hydro
```

### 6. Development Tools Setup

```bash
mise trust
mise i
```

### 7. macOS Defaults

Run the defaults script or apply manually:

```bash
./scripts/osx-defaults.sh
```

<details>
<summary>Manual commands</summary>

#### Keyboard Settings

```bash
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 1
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
```

#### Finder - Show Hidden Files

```bash
defaults write com.apple.finder AppleShowAllFiles YES
```

#### Trackpad - Disable Four Finger Pinch

```bash
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 0
```

</details>

### 8. Create Developer Directory

```bash
mkdir ~/Developer
```
