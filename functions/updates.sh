#!/bin/bash
scriptname="updates.sh"

_update_desktop() {
	if [ $ostype == "Desktop" ]; then
		clear
		echo "Updating Operating System"
		sudo DEBIAN_FRONTEND=nointeractive apt --fix-broken install -y
		sudo apt update
		sudo DEBIAN_FRONTEND=nointeractive apt install ubuntu-restricted-extras -y
		sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
		sudo DEBIAN_FRONTEND=nointeractive apt install mdadm net-tools finger xfsprogs dkms build-essential apt-utils ssh snap shfmt -y
		sudo DEBIAN_FRONTEND=nointeractive apt install gparted bolt gedit gdebi smartmontools smbclient p7zip-full mesa-utils git -y
		if [ $osversion == "20.04" ]; then
			sudo DEBIAN_FRONTEND=nointeractive apt install libxml2:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libatk-adaptor:i386 -y
		fi
		sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
		sudo DEBIAN_FRONTEND=nointeractive apt --fix-broken install -y
	fi
}

_update_server() {
	if [ $ostype == "Server" ]; then
		clear
		echo "Updating Operating System"
		sudo DEBIAN_FRONTEND=nointeractive apt --fix-broken install -y
		sudo apt update
		sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
		sudo DEBIAN_FRONTEND=nointeractive apt install build-essential bolt finger smartmontools p7zip-full smbclient network-manager ssh dkms samba cups mdadm net-tools -y
		if [ $osversion == "20.04" ]; then
			sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade linux-generic-hwe-20.04 -y
		fi
		if [ $osversion == "22.04" ]; then
			sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade linux-generic-hwe-22.04 -y
		fi
		sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
		sudo DEBIAN_FRONTEND=nointeractive apt --fix-broken install -y
	fi
}
