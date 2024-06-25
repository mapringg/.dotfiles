cd /tmp
wget -O sesh.tar.gz "https://github.com/joshmedeski/sesh/releases/latest/download/sesh_Linux_x86_64.tar.gz"
tar -xf sesh.tar.gz
sudo install sesh /usr/local/bin
rm -rf sesh sesh.tar.gz
cd -
