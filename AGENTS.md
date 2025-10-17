# Repository Guidelines

## Project Structure & Module Organization
- Root: `install.sh` orchestrates bootstrap; `Brewfile` pins taps, CLI tools, GUI apps.
- `shell/`: zsh profiles stowed into `~/.zshrc` and `~/.zprofile`.
- `xdg/.config/`: mirrors `~/.config/` for nvim, git, ghostty, starship, mise; keep subdirectories 1:1.
- New tool configs belong in stow-ready trees; validate with `stow --simulate <package>`.

## Build, Test, and Development Commands
- `./install.sh`: clean dead links, stow `shell` and `xdg`.
- `stow --simulate shell`: preview link map before committing structure changes.
- `brew bundle --file Brewfile`: sync Homebrew packages defined here.
- `mise install`: install runtimes declared in `mise.toml`.

## Coding Style & Naming Conventions
- Shell, config files: two-space indent; align related exports and alias blocks.
- Guard host-specific paths behind `if command -v …` checks in `shell/.zshrc`.

## Testing Guidelines
- `zsh -n shell/.zshrc`: lint shell startup.
- `stow --no-folding --simulate xdg`: ensure symlink targets exist.
- `mise doctor`: confirm runtime hooks after version updates; restart shell session.

## Commit & Pull Request Guidelines
- Commits stay short, imperative (`add neovim`, `swap ghostty to catppuccin`); group related dotfiles.
- Include rationale or manual follow-ups (e.g., rerun `brew bundle`) in bodies.
- Pull requests list impacted tools, link issues, attach theming screenshots when relevant.

## Security & Configuration Tips
- Keep secrets, SSH keys, tokens outside git; prefer ignored `.local` overrides or keychain storage.
- Verify new binaries before adding to `Brewfile`; document manual install steps if needed.
- Maintain portability by wrapping environment-specific tweaks in capability guards.
