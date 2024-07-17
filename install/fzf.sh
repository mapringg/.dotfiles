cd /tmp
FZF_VERSION=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -sLo fzf.tar.gz "https://github.com/junegunn/fzf/releases/latest/download/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
tar -xf fzf.tar.gz fzf
sudo install fzf /usr/local/bin
rm fzf.tar.gz fzf
cd -
