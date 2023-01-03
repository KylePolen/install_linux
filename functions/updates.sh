#!/bin/bash
scriptname="updates.sh"

if [ -f ~/install/flags/$scriptname ]; then
	exit
fi

source ~/install/functions/global.sh
source ~/install/functions/base_functions.sh

_update_desktop() {
	_os_check
	if [ $ostype == "Desktop" ]; then
		clear
		echo "Updating Operating System"
		sudo apt update
		sudo DEBIAN_FRONTEND=nointeractive apt install ubuntu-restricted-extras -y
		sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
		sudo DEBIAN_FRONTEND=nointeractive apt install mdadm net-tools finger xfsprogs dkms build-essential apt-utils ssh snap shfmt -y
		sudo DEBIAN_FRONTEND=nointeractive apt install gparted bolt gedit gdebi smartmontools mesa-utils git -y
		if [ $osversion == "20.04" ]; then
			sudo DEBIAN_FRONTEND=nointeractive apt install libxml2:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libatk-adaptor:i386 -y
		fi
		sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
	fi
}

_update_server() {
	_os_check
	if [ $ostype == "Server" ]; then
		clear
		echo "Updating Operating System"
		sudo apt update
		sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
		sudo DEBIAN_FRONTEND=nointeractive apt install build-essential bolt finger smartmontools network-manager ssh dkms samba cups mdadm net-tools -y
		if [ $osversion == "20.04" ]; then
			sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade linux-generic-hwe-20.04 -y
		fi
		if [ $osversion == "22.04" ]; then
			sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade linux-generic-hwe-22.04 -y
		fi
		sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
	fi
}

_update_desktop
_update_server

#Writing Completion Flag
touch ~/install/flags/$scriptname
