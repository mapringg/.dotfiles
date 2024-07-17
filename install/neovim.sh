ORIGINAL_DIR=$(pwd)
mkdir ~/build && cd ~/build
sudo apt-get install ninja-build gettext cmake unzip curl build-essential
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
git checkout stable
sudo make install
cd "$ORIGINAL_DIR"
