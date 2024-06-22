gsettings set org.gnome.shell app-picker-layout "[]"
for i in {1..9}; do gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"; done
