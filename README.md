# Main

```sh
sudo apt install stow curl
stow . -t ~
for file in install/*.sh; do bash "$file"; done
```
