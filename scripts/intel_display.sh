#!/bin/bash
scriptname="intel_display.sh"
clear

source ~/install/functions/global.sh
_os_check
_hostdata

if [ -f ~/install/flags/$scriptname ]; then
	exit
fi

if [ "$motherboard" != "NUC13SB" ]; then
	touch ~/install/flags/$scriptname
	exit
fi

if [ "$ostype" == "Server" ]; then
	clear
	echo 'This script is not intended for Server OS. The script will exit in five seconds and continue setup.'
	sleep 5
	touch ~/install/flags/$scriptname
	exit
fi

if [ ! -f ~/install/flags/intel_flag ]; then
	clear
	echo 'In order to support discrete and iGPU display, kernel 5.17 must be installed.' \
		'The system will auto reboot twice during installation. Please wait for a password' \
		'prompt after rebooting to continue this script where it left off.' | fold -s
	echo
	echo 'Press any key to continue...'
	read -p ""
	sudo apt-get install -y gpg-agent wget
	wget -qO - https://repositories.intel.com/graphics/intel-graphics.key |
		sudo gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
	echo 'deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu '$codename' arc' |
		sudo tee /etc/apt/sources.list.d/intel.gpu.$codename.list
	sudo apt update && sudo apt install -y linux-image-5.17.0-1019-oem
	if [ -f /etc/profile.d/run ]; then
		sudo rm /etc/profile.d/run
	fi
	echo "sleep 5" | sudo tee -a /etc/profile.d/$scriptname
	echo 'gnome-terminal -- ~/install/scripts/'$scriptname'' | sudo tee -a /etc/profile.d/$scriptname
	sudo chmod +x /etc/profile.d/$scriptname
	touch ~/install/flags/intel_flag
	sudo reboot
fi
if [ -f ~/install/flags/intel_flag ]; then
	clear
	sudo apt-get update
	sudo apt-get -y install \
		gawk \
		dkms \
		linux-headers-$(uname -r) \
		libc6-dev udev
	sudo apt-get install -y intel-platform-vsec-dkms intel-platform-cse-dkms
	sudo apt-get install -y intel-i915-dkms intel-fw-gpu
	sudo apt-get install -y \
		intel-opencl-icd intel-level-zero-gpu level-zero \
		intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
		libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri \
		libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers \
		mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all
	sudo apt-get install -y \
		libigc-dev \
		intel-igc-cm \
		libigdfcl-dev \
		libigfxcmrt-dev \
		level-zero-dev
	sudo dpkg --add-architecture i386
	sudo apt-get update
	sudo apt-get install -y \
		udev mesa-va-drivers:i386 mesa-common-dev:i386 mesa-vulkan-drivers:i386 \
		libd3dadapter9-mesa-dev:i386 libegl1-mesa:i386 libegl1-mesa-dev:i386 \
		libgbm-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev:i386 \
		libgles2-mesa:i386 libgles2-mesa-dev:i386 libosmesa6:i386 \
		libosmesa6-dev:i386 libwayland-egl1-mesa:i386 libxatracker2:i386 \
		libxatracker-dev:i386 mesa-vdpau-drivers:i386 libva-x11-2:i386
	sudo rm ~/install/flags/intel_flag
	sudo rm /etc/profile.d/$scriptname
	echo "sleep 5" | sudo tee -a /etc/profile.d/$scriptname
	echo 'gnome-terminal -- ~/install/master.sh' | sudo tee -a /etc/profile.d/master.sh
	touch ~/install/flags/$scriptname
	sudo reboot
fi
