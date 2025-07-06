mkdir -p ~/.config/lazygit
mkdir -p ~/.config/mise
mkdir -p ~/.gemini
mkdir -p ~/.ssh
mkdir -p ~/.config/ghostty

ln -nsf ~/.dotfiles/.config/lazygit/config.yml ~/.config/lazygit/config.yml
ln -nsf ~/.dotfiles/.config/mise/config.toml ~/.config/mise/config.toml

ln -nsf ~/.dotfiles/.gemini/settings.json ~/.gemini/settings.json

ln -nsf ~/.dotfiles/.ssh/config ~/.ssh/config

ln -nsf ~/.dotfiles/apple/.config/ghostty/config ~/.config/ghostty/config
ln -nsf ~/.dotfiles/apple/.p10k.zsh ~/.p10k.zsh
ln -nsf ~/.dotfiles/apple/.shell-integration.zsh ~/.shell-integration.zsh
ln -nsf ~/.dotfiles/apple/.zprofile ~/.zprofile
ln -nsf ~/.dotfiles/apple/.zshrc ~/.zshrc

ln -nsf ~/.dotfiles/.gitconfig ~/.gitconfig