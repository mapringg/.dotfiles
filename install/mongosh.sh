cd /tmp
MONGOSH_VERSION=$(curl -s "https://api.github.com/repos/mongodb-js/mongosh/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -sLo mongosh.tar.gz "https://github.com/mongodb-js/mongosh/releases/latest/download/mongosh-${MONGOSH_VERSION}-linux-x64.tgz"
tar -xf mongosh.tar.gz
MONGOSH_DIR="mongosh-${MONGOSH_VERSION}-linux-x64"
sudo install ${MONGOSH_DIR}/bin/mongosh /usr/local/bin
rm -rf mongosh.tar.gz ${MONGOSH_DIR}
cd -
