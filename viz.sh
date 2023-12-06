#!/bin/bash
scriptname="viz.sh"
clear

if [ $ostype == "Server" ]; then
	sudo DEBIAN_FRONTEND=nointeractive apt install net-tools -y
	nics="$(ip --brief address show | awk '$1 != "lo" { print $1 }')"
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
		length=${#nicnum}
		echo '    '$nicnum':' | sudo tee -a /etc/netplan/01-netcfg.yaml
		if [ $length -le 10 ]; then
			echo '      dhcp4: true' | sudo tee -a /etc/netplan/01-netcfg.yaml
		else
			echo '      dhcp4: false' | sudo tee -a /etc/netplan/01-netcfg.yaml
		fi	
		echo '      optional: true' | sudo tee -a /etc/netplan/01-netcfg.yaml
	done
fi

clear
echo "Resetting machine ID and acquiring unique IP"
if [ -f /etc/machine-id ]; then
	sudo rm /etc/machine-id
fi
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo netplan generate
sudo netplan apply

until ping -c1 www.google.com >/dev/null 2>&1; do :; done

sudo apt install git -y && git clone https://github.com/KylePolen/install_linux.git ~/install && cd ~/install && sudo chmod -R +x * && ./imaging.sh