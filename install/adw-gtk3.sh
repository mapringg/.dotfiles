cd /tmp
ADW_GTK3_VERSION=$(curl -s "https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -sLo adw-gtk3.tar.xz "https://github.com/lassekongo83/adw-gtk3/releases/latest/download/adw-gtk3v${ADW_GTK3_VERSION}.tar.xz"
mkdir -p ~/.local/share/themes
tar -xf adw-gtk3.tar.xz -C ~/.local/share/themes
rm adw-gtk3.tar.xz
cd -
