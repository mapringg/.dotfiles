sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow syncthing

sudo ufw allow in on tailscale0 to any port 22
sudo ufw allow 41641/udp

sudo ufw enable
