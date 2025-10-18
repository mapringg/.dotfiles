# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

Dotfiles repo using GNU stow for symlink management. Three main packages:
- `shell/` - shell configs (.zshrc, .bashrc, .zprofile)
- `ai/` - AI tool configs (.claude/settings.json, .claude/CLAUDE.md)
- `xdg/` - XDG-compliant configs (mise, starship, git, ghostty)

## Installation

```bash
./install.sh
```

Removes broken symlinks, then stows all three packages (ai, shell, xdg) into home directory.

## Package Management

**Add/modify configs:**
1. Edit files in respective package dir (shell/ai/xdg)
2. Re-stow: `stow <package>` (e.g., `stow shell`)
3. Or restow all: `./install.sh`

**Stow creates symlinks:** `~/.zshrc -> ~/.dotfiles/shell/.zshrc`

## Shell Configuration (.zshrc)

**Tool integrations:**
- `mise` - runtime version manager (Node.js, Bun, global npm tools)
- `starship` - minimal prompt (cyan theme, git status)
- `zoxide` - smart cd replacement
- `fzf` - fuzzy finder with bat preview

**Custom aliases:**
- `cd` -> `zd` (zoxide wrapper with fallback)
- `ls` -> `eza` (modern ls with icons)
- `lg` -> `lazygit`

## Development Tools

**Mise config** (xdg/.config/mise/config.toml):
- Node.js LTS with corepack enabled
- Bun (npm backend via `npm.bun = true`)
- Global tools: `@antfu/ni`, Claude Code, Codex, Gemini CLI, AMP

**Brewfile packages:**
- Modern CLI: bat, eza, fd, ripgrep, fzf
- Git tools: gh, lazygit
- Dev: mise, stow
- Network: tailscale, wireguard-tools
- Apps: ghostty (terminal), VSCode

## Testing Changes

After modifying shell configs: `source ~/.zshrc`
After modifying mise: `mise doctor` to verify
After modifying starship: check with `starship config`
