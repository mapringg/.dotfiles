cd /tmp
GH_VERSION=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
wget -O gh.deb "https://github.com/cli/cli/releases/latest/download/gh_${GH_VERSION}_linux_amd64.deb"
sudo apt install -y ./gh.deb
rm gh.deb
cd -
