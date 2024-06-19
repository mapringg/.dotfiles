cd /tmp
MONGOSH_VERSION=$(curl -s "https://api.github.com/repos/mongodb-js/mongosh/releases/latest " | grep -Po '"tag_name": "v\K[^"]*')
wget -O mongosh.deb "https://github.com/mongodb-js/mongosh/releases/latest/download/mongodb-mongosh_${LATEST_RELEASE}_amd64.deb"
sudo apt install -y ./mongosh.deb
rm mongosh.deb
cd -
