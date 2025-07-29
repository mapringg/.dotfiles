# Dotfiles

This repository contains my personal dotfiles with platform-specific configurations. The setup is organized by platform, with Apple-specific configurations in the `apple/` directory and Arch Linux-specific configurations in the `archlinux/` directory. Shared configurations are located in the root.

## Setup

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/mapringg/.dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
    ```

2.  **Run the setup script:**

    ```bash
    ./install.sh
    ```

The script will create symbolic links from the configuration files in this repository to their appropriate locations in your home directory.

## How It Works

This setup uses a single `install.sh` script to manage symbolic links. The repository is organized as follows:

- **`apple/`** - Apple/macOS-specific configurations (Bash, Ghostty).
- **`archlinux/`** - Arch Linux-specific configurations (Hyprland, Waybar, Alacritty, Bash).
- **Root directories** - Shared configurations that work across platforms:
  - `.config/` - Application configurations (lazygit, mise, nvim, etc.).
  - `.ssh/` - SSH configuration.
  - `gemini/` & `claude/` - AI tool settings.
  - `.gitconfig` - Git configuration.

### Key Configuration Files

#### Apple-Specific
- **Shell**: `apple/.bash_profile`, `apple/.bashrc`, and `apple/bash/*`
- **Terminal**: `apple/.config/ghostty/config`

#### Arch Linux-Specific
- **Window Manager**: `archlinux/.config/hypr/hyprland.conf`
- **Status Bar**: `archlinux/.config/waybar/config` and `style.css`
- **Terminal**: `archlinux/.config/alacritty/alacritty.toml`
- **Application Launcher**: `archlinux/.config/wofi/config`
- **Shell**: `archlinux/.bashrc`, `archlinux/.bash_profile`, and `archlinux/bash/*`

#### Shared
- **Application Configs**: `.config/lazygit/`, `.config/mise/`, `.config/nvim/`
- **SSH**: `.ssh/config`
- **Git**: `.gitconfig`
- **AI Tools**: `gemini/` and `claude/`

To add a new configuration file, place it in the appropriate directory and update the `install.sh` script.

## Updating

To update your dotfiles, simply pull the latest changes:

```bash
cd ~/.dotfiles
git pull
```