# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a personal dotfiles repository with platform-specific configurations. The repository follows a structured approach to organize configuration files by platform:

- **`apple/`** - Apple/macOS-specific configurations (shell configs, terminal settings)
- **`archlinux/`** - Arch Linux-specific configurations (currently empty, same structure as apple when populated)
- **Root directories** - Shared configurations that work across platforms:
  - **`.config/`** - Application configurations (lazygit, mise, etc.)
  - **`.ssh/`** - SSH configuration and keys
  - **`.gemini/`** - AI tool settings
  - **`.gitconfig`** - Git configuration

## Setup and Management Commands

### Initial Setup
```bash
# No special dependencies required - uses standard Unix commands

# Clone and setup dotfiles
git clone https://github.com/mapringg/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run platform-specific setup
./apple/install.sh          # For macOS/Apple
./archlinux/install.sh      # For Arch Linux (when available)
```

### Key Operations
- **Setup/Install dotfiles**: `./apple/install.sh` - Creates symbolic links for all configurations
- **Update dotfiles**: `git pull` in the `.dotfiles` directory
- **Add new config**: Place in appropriate platform directory (`apple/`, `archlinux/`) or shared directory, then update the relevant install script

## Symlink Structure

The install script (`apple/install.sh`) creates symbolic links as follows:
- **Shared configs**: `ln -nsf ~/.dotfiles/.config/lazygit/config.yml ~/.config/lazygit/config.yml`
- **Apple-specific configs**: `ln -nsf ~/.dotfiles/apple/.zshrc ~/.zshrc`
- **SSH configs**: `ln -nsf ~/.dotfiles/.ssh/config ~/.ssh/config`
- **Git config**: `ln -nsf ~/.dotfiles/.gitconfig ~/.gitconfig`

When modifying configurations, understand that files are symlinked - changes in the repository immediately affect the live system.

## Key Configuration Files

### Apple-Specific Files
- **Shell**: `apple/.p10k.zsh` (Powerlevel10k theme), `apple/.shell-integration.zsh`, `apple/.zshrc`, `apple/.zprofile`
- **Terminal**: `apple/.config/ghostty/config`

### Shared Files
- **Git**: `.gitconfig`
- **AI Tools**: `.gemini/settings.json`
- **Development**: `.config/mise/config.toml` (runtime manager)
- **Version Control**: `.config/lazygit/config.yml`
- **SSH**: `.ssh/config`