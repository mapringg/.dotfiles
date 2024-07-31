cd /tmp
wget -O tldr "https://github.com/dbrgn/tealdeer/releases/latest/download/tealdeer-linux-x86_64-musl"
sudo install tldr /usr/local/bin
rm tldr
cd -
