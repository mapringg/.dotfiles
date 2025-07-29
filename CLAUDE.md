# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a personal dotfiles repository with platform-specific configurations. The repository follows a structured approach to organize configuration files by platform:

- **`apple/`** - Apple/macOS-specific configurations (Bash, Ghostty).
- **`archlinux/`** - Arch Linux-specific configurations (Hyprland, Waybar, Alacritty, Bash).
- **Root directories** - Shared configurations that work across platforms:
  - `.config/` - Application configurations (lazygit, mise, nvim, etc.).
  - `.ssh/` - SSH configuration and keys.
  - `gemini/` & `claude/` - AI tool settings.
  - `.gitconfig` - Git configuration.

## Setup and Management Commands

### Initial Setup
```bash
# No special dependencies required - uses standard Unix commands

# Clone and setup dotfiles
git clone https://github.com/mapringg/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the main install script
./install.sh
```

### Key Operations
- **Setup/Install dotfiles**: `./install.sh` - Creates symbolic links for all configurations.
- **Update dotfiles**: `git pull` in the `.dotfiles` directory.
- **Add new config**: Place in the appropriate directory and update `install.sh`.

## Symlink Structure

The `install.sh` script creates symbolic links for all managed configurations. Examples:
- **Shared configs**: `ln -nsf ~/.dotfiles/.config/lazygit/config.yml ~/.config/lazygit/config.yml`
- **Apple-specific configs**: `ln -nsf ~/.dotfiles/apple/.bashrc ~/.bashrc`
- **SSH configs**: `ln -nsf ~/.dotfiles/.ssh/config ~/.ssh/config`
- **Git config**: `ln -nsf ~/.dotfiles/.gitconfig ~/.gitconfig`

When modifying configurations, understand that files are symlinked - changes in the repository immediately affect the live system.

## Key Configuration Files

### Apple-Specific Files
- **Shell**: `apple/.bash_profile`, `apple/.bashrc`, and `apple/bash/*`
- **Terminal**: `apple/.config/ghostty/config`

### Arch Linux-Specific Files
- **Window Manager**: `archlinux/.config/hypr/hyprland.conf`
- **Status Bar**: `archlinux/.config/waybar/config` and `style.css`
- **Terminal**: `archlinux/.config/alacritty/alacritty.toml`
- **Application Launcher**: `archlinux/.config/wofi/config`
- **Shell**: `archlinux/.bashrc`, `archlinux/.bash_profile`, and `archlinux/bash/*`

### Shared Files
- **Git**: `.gitconfig`
- **AI Tools**: `gemini/` and `claude/`
- **Development**: `.config/mise/config.toml`
- **Version Control**: `.config/lazygit/config.yml`
- **SSH**: `.ssh/config`
