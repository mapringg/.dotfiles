# AGENTS.md

## Build/Install Commands
- `./install.sh` - Install dotfiles using GNU Stow (links configs to home directory)
- `stow <package>` - Manually stow individual packages (ai, shell, xdg)

## Architecture & Structure
- **Packages**: ai/ (Claude/Codex configs), shell/ (bash/zsh), xdg/ (.config apps)
- **Tool**: GNU Stow for symlink management
- **Dependencies**: Homebrew (Brewfile) for macOS tools
- **Cross-platform**: Separate configs for macOS/Linux (bash vs zsh)

## Code Style Guidelines
- **Shell scripts**: Standard bash/zsh syntax, error handling with `set -e`
- **Naming**: Lowercase, descriptive names; functions use `snake_case`
- **Imports**: Tool integrations check `command -v` before sourcing
- **Formatting**: 2-space indentation, comments on separate lines
- **Error handling**: Use `|| return 1` for functions, `>&2` for error messages
- **Environment**: Export variables early, conditional tool loading
- **Aliases**: Short, memorable; functions for complex operations

## Existing Rules
- **Claude**: Be extremely concise. Sacrifice grammar for concision. (ai/.claude/CLAUDE.md)
- **Codex**: Same conciseness rule. (ai/.codex/AGENTS.md)

## Key Tools & Integrations
- Starship (prompt), Mise (version manager), Zoxide (cd), FZF (fuzzy finder)
- Eza (ls replacement), Bat (cat with syntax), LazyGit (git UI)
- Ripgrep, FD, Tealdeer (tldr), Ghostty (terminal)

## Git Workflow
- Default branch: main
- Rebase on pull
- Aliases: co, br, ci, st
- Editor: VS Code
