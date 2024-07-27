cd ~/.dotfiles

sudo apt install -y \
  stow curl xsel \
  fd-find bat zsh python3-venv \
  tmux ripgrep wireguard-tools \
  build-essential

sudo ln -s /usr/bin/batcat /usr/bin/bat
sudo ln -s /usr/bin/fdfind /usr/bin/fd

stow . -t ~
for file in install/*.sh; do bash "$file"; done

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
bat cache --build

mise install

echo "Please install tmux plugins by pressing prefix + I"
echo "Please install neovim plugins by opening neovim"

cd -
