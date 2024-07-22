sudo apt install -y \
  fd-find bat zsh \
  zoxide tmux tealdeer \
  eza ripgrep wireguard-tools

sudo ln -s /usr/bin/batcat /usr/bin/bat
sudo ln -s /usr/bin/fdfind /usr/bin/fd

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

bat cache --build
