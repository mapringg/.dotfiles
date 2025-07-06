# Dotfiles

This repository contains my personal dotfiles with platform-specific configurations. The setup is organized by platform, with Apple-specific configurations in the `apple/` directory and shared configurations in the root directories.

## Prerequisites

No special tools are required - the setup script uses standard Unix commands (`ln`, `mkdir`) to create symbolic links.

## Setup

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/mapringg/.dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
    ```

2.  **Run the platform-specific setup script:**

    **For macOS/Apple:**
    ```bash
    ./apple/install.sh
    ```

    **For Arch Linux:**
    ```bash
    ./archlinux/install.sh  # (when available)
    ```

The script will create symbolic links from the configuration files in this repository to their appropriate locations in your home directory.

## How It Works

This setup uses direct symbolic links to manage configurations. The repository is organized as follows:

- **`apple/`** - Apple/macOS-specific configurations (shell configs, terminal settings)
- **`archlinux/`** - Arch Linux-specific configurations (Hyprland, Waybar, Alacritty, bash)
- **Root directories** - Shared configurations that work across platforms:
  - `.config/` - Application configurations (lazygit, mise, etc.)
  - `.ssh/` - SSH configuration
  - `.gemini/` - AI tool settings
  - `.gitconfig` - Git configuration

### Apple-Specific Files
- Shell configurations: `.zshrc`, `.zprofile`, `.p10k.zsh`, `.shell-integration.zsh`
- Terminal configuration: `apple/.config/ghostty/config`

### Arch Linux-Specific Files
- Window manager: `archlinux/.config/hypr/hyprland.conf` (Hyprland configuration)
- Status bar: `archlinux/.config/waybar/config` and `archlinux/.config/waybar/style.css`
- Terminal: `archlinux/.config/alacritty/alacritty.toml`
- Application launcher: `archlinux/.config/wofi/config`
- Shell configurations: `archlinux/.bashrc`, `archlinux/.bash_profile`

### Shared Files
- Application configs: `.config/lazygit/config.yml`, `.config/mise/config.toml`
- SSH configuration: `.ssh/config`
- Git configuration: `.gitconfig`
- AI tool settings: `.gemini/settings.json`

To add a new configuration file, place it in the appropriate platform directory (`apple/`, `archlinux/`) or shared directory, then update the relevant install script.

## Updating

To update your dotfiles, simply pull the latest changes from the repository:

```bash
cd ~/.dotfiles
git pull
```
