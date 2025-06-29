# Dotfiles

This repository contains my personal dotfiles. The setup process is automated via a script that uses `stow` to symlink configurations into their appropriate locations.

## Prerequisites

Before you begin, ensure you have `stow` installed.

- **macOS (with Homebrew):** `brew install stow`
- **Debian/Ubuntu:** `sudo apt-get install stow`

## Setup

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/mapringg/.dotfiles.git ~/.dotfiles
    cd ~/.dotfiles

    ```

2.  **Run the setup script:**

    ```bash
    ./setup.sh
    ```

The script will symlink the contents of the directories within this repository to your home directory (`$HOME`).

## How It Works

This setup uses `stow` to manage symlinks. Each top-level directory in this repository (e.g., `home`, `zsh`, `.config`) is a "stow package."

- Files and directories within the `home` directory are symlinked directly into `$HOME`. For example, `home/.gitconfig` becomes `~/.gitconfig`.
- Files and directories within other packages are symlinked to their corresponding locations. For example, `zsh/.zshrc` becomes `~/.zshrc`, and `.config/lazygit/config.yml` becomes `~/.config/lazygit/config.yml`.

To add a new configuration file for your home directory, simply add it to the `home` directory in this repository and re-run `./setup.sh`.

## Updating

To update your dotfiles, simply pull the latest changes from the repository:

```bash
cd ~/.dotfiles
git pull
```
