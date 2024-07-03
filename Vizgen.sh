#!/bin/bash
scriptname=vizgen.sh
clear

###Run updates
sudo DEBIAN_FRONTEND=nointeractive apt --fix-broken install -y
sudo apt update
sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
sudo DEBIAN_FRONTEND=nointeractive apt install build-essential make bolt finger pv smartmontools p7zip-full smbclient network-manager ssh dkms samba cups mdadm net-tools -y
sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade linux-generic-hwe-20.04 -y
sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
sudo DEBIAN_FRONTEND=nointeractive apt --fix-broken install -y

###NVIDIA Driver
sudo DEBIAN_FRONTEND=nointeractive add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt update
sudo DEBIAN_FRONTEND=nointeractive apt -y install nvidia-driver-555 --no-install-recommends

#Broadcom 9560
#sudo wget https://github.com/BenjaminLentini/StorCLI/raw/main/megaraid_sas-07.729.00.00-1dkms.noarch.deb
sudo wget https://github.com/KylePolen/install_linux/blob/3d29b2f1ad9f3655a4fd5f182bec053ad311e6d2/megaraid_sas-07.729.00.00-1dkms.noarch.deb
sudo wget https://github.com/BenjaminLentini/StorCLI/raw/main/storcli_007.2908.0000.0000_all.deb
sudo dpkg -i *
echo 'export PATH="/opt/MegaRAID/storcli:$PATH"' >> ~/.bashrc
export PATH="/opt/MegaRAID/storcli:$PATH"
sudo apt update
sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
sudo DEBIAN_FRONTEND=nointeractive apt --fix-broken install -y

###Format and mount RAID (Auto)
sudo echo "label: gpt" | sudo sfdisk --force /dev/sda
sudo echo ';' | sudo sfdisk --force /dev/sda
echo "y" | sudo mkfs -t ext4 /dev/sda1
uuid="$(sudo blkid -s UUID -o value /dev/sda1)"
echo "#Broadcom 9560 - /dev/sda - added by Puget Systems" | sudo tee -a /etc/fstab
echo "UUID=$uuid /raid ext4 defaults 0 0" | sudo tee -a /etc/fstab

###GRUB fix
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="amd-iommu=on iommu=pt pci=nommconf"/' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=5/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=menu/g' /etc/default/grub
sudo update-grub

#Network fix
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
sudo netplan generate && sudo netplan apply

sudo rm -R ~/*
sudo reboot

