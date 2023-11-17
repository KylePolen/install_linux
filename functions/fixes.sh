#!/bin/bash
scriptname="fixes.sh"
clear

###Motherboard Fixes
#Audio drivers and GRUB fixes
_mobofix() {
	if [ "$motherboard" == "Pro WS WRX80E-SAGE SE WIFI" ]; then
		if [ $ostype == "Desktop" ]; then
			sudo cp ~/install/assets/fixes/source/90-pulseaudio.rules /lib/udev/rules.d/90-pulseaudio.rules
			sudo cp ~/install/assets/fixes/source/asus-wrx80-usb-audio.conf /usr/share/pulseaudio/alsa-mixer/profile-sets/asus-wrx80-usb-audio.conf
		fi
		if [ $ostype == "Desktop" ]; then
			sudo sed -i 's/splash"/splash amd-iommu=on iommu=pt pci=nommconf"/' /etc/default/grub
		fi
		if [ $ostype == "Server" ]; then
			sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="amd-iommu=on iommu=pt pci=nommconf"/' /etc/default/grub
		fi

	fi
	if [ "$motherboard" == "ProArt X670E-CREATOR WIFI" ]; then
		if [ $ostype == "Desktop" ]; then
			sudo sed -i 's/splash"/splash amd-iommu=on iommu=pt pci=nommconf"/' /etc/default/grub
		fi
		if [ $ostype == "Server" ]; then
			sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="amd-iommu=on iommu=pt pci=nommconf"/' /etc/default/grub
		fi
	fi
	if grep -q '"name":"Gigabyte TRX40 AORUS PRO WIFI (Rev. 1.1)"' ~/install/orderdata/orderdata; then
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
	if grep -q '"company":"Toyota Research' ~/install/orderdata/orderdata; then
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
_netmanold() {
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
}

#Install, configure and enable Network Manager
_netman() {
	if [ $ostype == "Server" ]; then
		sudo DEBIAN_FRONTEND=nointeractive apt install net-tools -y
		nics="$(ip --brief address show | awk '$1 != "lo" { print $1 }')":
		nics_array=($nics)

		if [ ! -f /etc/cloud/cloud-init.disabled ]; then
			sudo touch /etc/cloud/cloud-init.disabled
		fi
		if [ -f /etc/netplan/01-netcfg.yaml ]; then
			sudo rm /etc/netplan/01-netcfg.yaml
			sudo touch /etc/netplan/01-netcfg.yaml
		fi

		echo 'network:' | sudo tee -a /etc/netplan/01-netcfg.yaml
		echo '  version: 2' | sudo tee -a /etc/netplan/01-netcfg.yaml
		echo '  ethernets:' | sudo tee -a /etc/netplan/01-netcfg.yaml

		for nicnum in "${nics_array[@]}"; do
			echo '    '$nicnum | sudo tee -a /etc/netplan/01-netcfg.yaml
			echo '      dhcp4: true' | sudo tee -a /etc/netplan/01-netcfg.yaml
			echo '      optional: true' | sudo tee -a /etc/netplan/01-netcfg.yaml
		done
		sudo netplan generate && sudo netplan apply
	fi
}

###Display GRUB
_grubfix() {
	sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
	sudo sed -i 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=menu/g' /etc/default/grub
	sudo update-grub
}
