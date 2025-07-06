mkdir -p ~/.config/lazygit
mkdir -p ~/.config/mise

mkdir -p ~/.gemini
mkdir -p ~/.ssh

mkdir -p ~/.config/alacritty
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wofi


ln -nsf ~/.dotfiles/.config/lazygit/config.yml ~/.config/lazygit/config.yml
ln -nsf ~/.dotfiles/.config/mise/config.toml ~/.config/mise/config.toml

ln -nsf ~/.dotfiles/.gemini/settings.json ~/.gemini/settings.json
ln -nsf ~/.dotfiles/.ssh/config ~/.ssh/config

ln -nsf ~/.dotfiles/archlinux/.config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -nsf ~/.dotfiles/archlinux/.config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf
ln -nsf ~/.dotfiles/archlinux/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
ln -nsf ~/.dotfiles/archlinux/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
ln -nsf ~/.dotfiles/archlinux/.config/hypr/monitors.conf ~/.config/hypr/monitors.conf
ln -nsf ~/.dotfiles/archlinux/.config/waybar/config ~/.config/waybar/config
ln -nsf ~/.dotfiles/archlinux/.config/waybar/style.css ~/.config/waybar/style.css
ln -nsf ~/.dotfiles/archlinux/.config/wofi/config ~/.config/wofi/config

ln -nsf ~/.dotfiles/archlinux/.bash_profile ~/.bash_profile
ln -nsf ~/.dotfiles/archlinux/.bashrc ~/.bashrc

ln -nsf ~/.dotfiles/.gitconfig ~/.gitconfig