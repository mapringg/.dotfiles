```sh
sudo apt install stow
stow . -t ~
for file in install/*.sh; do bash "$file"; done
```
