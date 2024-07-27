cd /tmp
GH_VERSION=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
wget -O gh.tar.gz "https://github.com/cli/cli/releases/latest/download/gh_${GH_VERSION}_linux_amd64.tar.gz"
tar -xf gh.tar.gz
sudo install gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin
rm -rf gh.tar.gz gh_${GH_VERSION}_linux_amd64
cd -
