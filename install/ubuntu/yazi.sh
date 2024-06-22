cd /tmp
wget -O yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
unzip yazi.zip
sudo install yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin
sudo install yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin
rm -rf yazi-x86_64-unknown-linux-gnu yazi.zip
cd -
