# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a personal dotfiles repository that uses GNU Stow for configuration management. The repository follows a structured approach to organize configuration files:

- **`home/`** - Files symlinked directly to `$HOME` (e.g., `.gitconfig`, `.p10k.zsh`)
- **`.config/`** - Application configurations symlinked to `~/.config/` (ghostty, lazygit, mise, etc.)
- **`zsh/`** - Zsh shell configuration files
- **`.ssh/`** - SSH configuration and keys
- **`bash/`** - Bash shell configurations

## Setup and Management Commands

### Initial Setup
```bash
# Install dependencies (macOS)
brew install stow

# Clone and setup dotfiles
git clone https://github.com/mapringg/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

### Key Operations
- **Setup/Install dotfiles**: `./setup.sh` - Uses stow to symlink all configurations
- **Update dotfiles**: `git pull` in the `.dotfiles` directory
- **Add new config**: Place in appropriate directory (`home/`, `.config/`, etc.) and re-run `./setup.sh`

## Stow Package Structure

The setup script (`setup.sh`) stows packages as follows:
- `stow zsh` → Links zsh configs to `$HOME`
- `stow home` → Links home directory files to `$HOME`  
- `stow .config -t "$HOME/.config"` → Links app configs to `~/.config/`
- `stow .ssh -t "$HOME/.ssh"` → Links SSH configs to `~/.ssh/`

When modifying configurations, understand that files are symlinked - changes in the repository immediately affect the live system.

## Key Configuration Files

- **Shell**: `.p10k.zsh` (Powerlevel10k theme), `.shell-integration.zsh`
- **Git**: `home/.gitconfig`
- **AI Tools**: `home/.aider.conf.yml`, `home/.gemini/settings.json`
- **Terminal**: `.config/ghostty/config`
- **Development**: `.config/mise/config.toml` (runtime manager)