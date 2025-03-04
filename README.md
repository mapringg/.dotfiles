# Dotfiles

This repository contains my personal dotfiles managed with GNU Stow.

## Setup

1. Clone this repository to your home directory:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Install GNU Stow if you don't have it already:
   ```bash
   # On Ubuntu/Debian/Linux Mint
   sudo apt-get install stow
   
   # On macOS with Homebrew
   brew install stow
   ```

## Usage

### For Linux Systems

On Linux systems, you need to modify your default `.bashrc` and `.profile` files to source the local configurations:

1. Add the following line at the end of your `~/.bashrc`:
   ```bash
   # Source local bashrc if it exists
   if [ -f ~/.bashrc.local ]; then
       source ~/.bashrc.local
   fi
   ```

2. Add the following line at the end of your `~/.profile`:
   ```bash
   # Source local profile if it exists
   if [ -f ~/.profile.local ]; then
       source ~/.profile.local
   fi
   ```

3. Use stow to symlink the bash configuration:
   ```bash
   stow bash
   ```

### For macOS Systems

On macOS systems, use stow to symlink the zsh configuration:

```bash
stow zsh
```

## Other Configurations

For other configurations that are common across systems:

```bash
stow bin
stow .config
# Add other stow commands for additional configurations
```

## Updating

To update your dotfiles:

1. Pull the latest changes:
   ```bash
   cd ~/.dotfiles
   git pull
   ```

2. Re-stow the packages if needed:
   ```bash
   stow -R bash  # On Linux
   stow -R zsh   # On macOS
   ```

## Unstowing

To remove the symlinks created by stow:

```bash
stow -D bash  # Remove bash symlinks
stow -D zsh   # Remove zsh symlinks
``` 