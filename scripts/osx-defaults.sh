#!/usr/bin/env bash
# macOS system defaults - safe to re-run
set -euo pipefail

echo "Configuring macOS defaults..."

# Keyboard Settings
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 1
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Finder - Show Hidden Files
defaults write com.apple.finder AppleShowAllFiles YES

# Trackpad - Disable Four Finger Pinch
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 0

# Restart Finder to apply changes
killall Finder || true

echo "macOS defaults configured!"
