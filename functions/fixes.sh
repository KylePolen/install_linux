#!/bin/bash
scriptname="fixes.sh"
clear

if [ -f ~/install/flags/$scriptname ]; then
	exit
fi

source ~/install/functions/global.sh

###Motherboard Fixes
#Audio drivers and GRUB fixes
_mobofix() {
	_hostdata
	_os_check
	if [ "$motherboard" == "Pro WS WRX80E-SAGE SE WIFI" ]; then
		if [ $ostype == "Desktop" ]; then
			sudo cp ~/install/assets/fixes/source/90-pulseaudio.rules /lib/udev/rules.d/90-pulseaudio.rules
			sudo cp ~/install/assets/fixes/source/asus-wrx80-usb-audio.conf /usr/share/pulseaudio/alsa-mixer/profile-sets/asus-wrx80-usb-audio.conf
		fi
		sudo sed -i 's/splash"/splash amd-iommu=on iommu=pt"/' /etc/default/grub
	fi
	if [ "$motherboard" == "ProArt X670E-CREATOR WIFI" ]; then
		sudo sed -i 's/splash"/splash amd-iommu=on iommu=pt"/' /etc/default/grub
	fi
	if grep -q '"name":"Gigabyte TRX40 AORUS PRO WIFI (Rev. 1.1)"' ~/install/orderdata; then
		if [ $ostype == "Desktop" ]; then
			sudo cp ~/install/assets/fixes/source/Realtek-ALC1220-VB-Desktop.conf /usr/share/alsa/ucm2/USB-Audio/Realtek-ALC1220-VB-Desktop.conf
			sudo cp ~/install/assets/fixes/source/Realtek-ALC1220-VB-Desktop-HiFi.conf /usr/share/alsa/ucm2/USB-Audio/Realtek-ALC1220-VB-Desktop-HiFi.conf
		fi
	fi
	sudo update-grub
}

###Master Accounts
#Toyota Disable 64bit BAR
_toyota() {
	if grep -q '"company":"Toyota Research Institute"' ~/install/orderdata; then
		clear
		echo "Disabling 64bit BAR Support"
		echo
		sleep 2s
		cd ~/install
		sudo chmod +x bootutil64e
		sudo ./assets/bootutil64e -NIC=1 -64d
		sudo ./assets/bootutil64e -NIC=2 -64d
		sudo ./assets/bootutil64e -NIC=3 -64d
		sudo ./assets/bootutil64e -NIC=4 -64d
		sudo ./assets/bootutil64e -NIC=5 -64d
		sleep 10s
	fi
}

###Network Fixes
#Install, configure and enable Network Manager
_netman() {
	_os_check
	if ! grep -q 'Vizgen, Inc.' ~/install/orderdata; then
		if [ $ostype == "Server" ]; then
			sudo DEBIAN_FRONTEND=nointeractive apt install network-manager net-tools -y
			sleep 2
			sudo touch /etc/cloud/cloud-init.disabled
			sudo bash -c 'cat << EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: NetworkManager
EOF'
			sudo netplan generate && sudo netplan apply
			sleep 2
		fi
	fi
}

_mobofix
_toyota
_netman

#Writing Completion Flag
touch ~/install/flags/$scriptname
