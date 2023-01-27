#!/bin/bash
scriptname="drivers.sh"
clear

#NVIDIA
_nvidia() {
	if lspci -v | grep -q NVIDIA; then
		sudo DEBIAN_FRONTEND=nointeractive add-apt-repository -y ppa:graphics-drivers/ppa
		sudo apt update
		if [ "$ostype" == "Desktop" ]; then
			if [ "$osversion" == "22.04" ]; then
				sudo DEBIAN_FRONTEND=nointeractive apt -y install nvidia-driver-525
			else
				sudo DEBIAN_FRONTEND=nointeractive apt -y install nvidia-driver-520
			fi	
		else
			if [ "$osversion" == "22.04" ]; then
				sudo DEBIAN_FRONTEND=nointeractive apt -y install nvidia-driver-525 --no-install-recommends
			else
				sudo DEBIAN_FRONTEND=nointeractive apt -y install nvidia-driver-520 --no-install-recommends
			fi
		fi		
	fi
}

#AMD iGPU
_amdigpu() {
	if [ "$motherboard" == "TUF GAMING B650M-PLUS WIFI" -o "$motherboard" == "ProArt X670E-CREATOR WIFI" -o "$motherboard" == "MAG B650M MORTAR WIFI (MS-7D76)" ]; then
		sudo DEBIAN_FRONTEND=nointeractive apt install ~/install/assets/drivers/amdgpu-install_5.3.50300-1_all.deb -y
		sudo amdgpu-install -y
	fi
}

#ASPEED
_aspeed() {
	if lspci -v | grep -q ASPEED; then
		sudo dpkg -i ~/assets/drivers/ast-drm-linux5.15.deb
	fi
}
