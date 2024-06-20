cd /tmp
MISE_VERSION=$(curl -s "https://api.github.com/repos/jdx/mise/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
curl -sLo mise.tar.gz "https://github.com/jdx/mise/releases/latest/download/mise-${MISE_VERSION}-linux-x64.tar.gz"
tar -xf mise.tar.gz mise
sudo install mise/bin/mise /usr/local/bin
rm -rf mise.tar.gz mise
cd -
