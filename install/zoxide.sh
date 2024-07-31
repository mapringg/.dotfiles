cd /tmp
ZOXIDE_VERSION=$(curl -s "https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -sLo zoxide.tar.gz "https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-${ZOXIDE_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar -xf zoxide.tar.gz zoxide
sudo install zoxide /usr/local/bin
rm zoxide.tar.gz zoxide
cd -
