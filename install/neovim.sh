cd /tmp
sudo apt-get install ninja-build gettext cmake unzip curl build-essential
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
git checkout stable
cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
rm -rf /tmp/neovim
cd ~
