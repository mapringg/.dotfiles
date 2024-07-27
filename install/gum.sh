cd /tmp
GUM_VERSION=$(curl -s "https://api.github.com/repos/charmbracelet/gum/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
wget -O gum.tar.gz "https://github.com/charmbracelet/gum/releases/latest/download/gum_${GUM_VERSION}_Linux_x86_64.tar.gz"
tar -xf gum.tar.gz
sudo install gum_${GUM_VERSION}_Linux_x86_64/gum /usr/local/bin
rm -rf gum.tar.gz gum_${GUM_VERSION}_Linux_x86_64
cd -
