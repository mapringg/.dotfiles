# Dotfiles Configuration Repository

Personal dotfiles and development environment configuration management.

## Project Structure

- `.config/` - Application configuration files (nvim, git, mise, opencode, starship)
- `.ssh/` - SSH configuration
- `install.sh` - Setup script for symlinking configurations
- `Brewfile` - Homebrew package definitions
- `.zshrc/.zprofile` - Shell configuration and aliases

## Code Standards

- No build/test commands - this is a configuration repository
- Shell scripts use bash best practices with proper error handling
- Lua configuration follows LazyVim conventions for Neovim
- JSON/TOML configuration files are properly formatted

## Conventions

- Symlink-based deployment via `install.sh` 
- OS-specific configurations (Linux vs macOS handling)
- Tool configuration is modular and composable
- Use mise for runtime version management
- Git config includes global ignore patterns
- Neovim setup uses LazyVim with TypeScript/Tailwind extras

**Important:** Do not run build or dev commands
