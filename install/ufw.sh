sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow in on tailscale0

sudo ufw enable
