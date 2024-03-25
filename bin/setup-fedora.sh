#!/bin/bash
setup_repos() {
	sudo dnf install \
		https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
	sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

	sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
}

update_groups() {
	sudo dnf swap ffmpeg-free ffmpeg --allowerasing
	sudo dnf groupupdate multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
	sudo dnf groupupdate sound-and-video
}

install_packages() {
	sudo dnf install stow gh zoxide bat ripgrep fd-find eza xsel \
		adw-gtk3-theme keepassxc syncthing brave-browser code gnome-extensions-app \
		docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_local_packages() {
	mkdir -p $HOME/.local/bin

	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	install lazygit $HOME/.local/bin

	LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazydocker.tar.gz lazydocker
	install lazydocker $HOME/.local/bin

	curl -sS https://starship.rs/install.sh | sh

	curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --no-update-rc
}

install_flatpaks() {
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install flathub com.getpostman.Postman
}

install_nvidia() {
	sudo dnf install akmod-nvidia
	sudo dnf install xorg-x11-drv-nvidia-cuda
	sudo dnf install nvidia-vaapi-driver
}

setup_secure_boot() {
	sudo dnf install akmod
	sudo /usr/sbin/kmodgenca -f
	sudo mokutil --import /etc/pki/akmods/certs/public_key.der
}

setup_packages() {
	dockerd-rootless-setuptool.sh install

	gh auth login
	gh extension install github/gh-copilot

	gsettings set org.gnome.shell app-picker-layout "[]"
	gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
}

enable_services() {
	systemctl --user start docker
	systemctl --user enable docker
	sudo loginctl enable-linger $(whoami)

	systemctl --user start syncthing.service
	systemctl --user enable syncthing.service
}

link_dotfiles() {
	# TODO: recheck this command
	gh repo clone .dotfiles
	stow -t $HOME -d .dotfiles -S $(ls -d .dotfiles/* | xargs -n 1 basename)
}

usage() {
	echo "$0: Install packages and software"
	echo
	echo "Usage: $0 [-suplfanbeh]"
	echo
	echo "-s: set up DNF repos"
	echo "-u: update groups: implies -s"
	echo "-p: install packages: implies -s"
	echo "-l: install local packages: implies -s"
	echo "-f: install flatpaks from flathub: also sets up flathub"
	echo "-a: do all of the above"
	echo "-n: install nvidia driver: implies -s"
	echo "-b: setup secure boot: implies -s"
	echo "-e: enable services"
	echo "-h: print this usage text and exit"
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

# parse options
while getopts "suplfanbeh" OPTION; do
	case $OPTION in
	s)
		setup_repos
		exit 0
		;;
	u)
		setup_repos
		update_groups
		exit 0
		;;
	p)
		setup_repos
		install_packages
		setup_packages
		enable_services
		exit 0
		;;
	l)
		install_local_packages
		exit 0
		;;
	f)
		install_flatpaks
		exit 0
		;;
	a)
		setup_repos
		update_groups
		install_packages
		setup_packages
		install_local_packages
		install_flatpaks
		enable_services
		exit 0
		;;
	n)
		setup_repos
		install_nvidia
		exit 0
		;;
	b)
		setup_repos
		setup_secure_boot
		exit 0
		;;
	e)
		enable_services
		exit 0
		;;
	h)
		usage
		exit 0
		;;
	?)
		usage
		exit 1
		;;
	esac
done
