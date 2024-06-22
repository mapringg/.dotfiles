cd /tmp
GUM_VERSION=$(curl -s "https://api.github.com/repos/charmbracelet/gum/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
wget -O gum.deb "https://github.com/charmbracelet/gum/releases/latest/download/gum_${GUM_VERSION}_amd64.deb"
sudo apt install -y ./gum.deb
rm gum.deb
cd -
