#!/bin/bash
scriptname=vizgen_automation.sh
clear

echo 'Password is "Password1!"'
echo ""
sudo clear

###Change Hostname
serial=$(sudo dmidecode -t 1 | grep -i 'Serial Number: ') && serial=${serial:15} && serial=${serial,,}
sudo hostnamectl set-hostname $serial
sudo sed -i "2s/.*/127.0.0.1	${serial}/" /etc/hosts

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
wget https://download.pugetsystems.com/Broadcom_9560/megaraid_sas-07.729.00.00-1dkms.noarch.deb -P ~
wget https://download.pugetsystems.com/Broadcom_9560/storcli_007.2908.0000.0000_all.deb -P ~
sudo dpkg -i ~/megaraid_sas-07.729.00.00-1dkms.noarch.deb
sudo dpkg -i ~/storcli_007.2908.0000.0000_all.deb
sudo rm ~/megaraid_sas-07.729.00.00-1dkms.noarch.deb
sudo rm ~/storcli_007.2908.0000.0000_all.deb
sudo ln -s /opt/MegaRAID/storcli/storcli64 /usr/local/bin/storcli64
sudo ln -s /opt/MegaRAID/storcli/storcli64 /usr/local/bin/storcli
sudo apt update
sudo DEBIAN_FRONTEND=nointeractive apt dist-upgrade -y
sudo DEBIAN_FRONTEND=nointeractive apt --fix-broken install -y

###Format and mount RAID (Auto)
drive="$(lsblk --noheadings -d -o NAME,TYPE,STATE,VENDOR | awk '$2 == "disk" { print $1 }')"
array=($drive)
for drive in "${array[@]}"; do
	rootcheck="$(lsblk --noheadings /dev/$drive -o NAME,MOUNTPOINT | awk '$2 == "/boot/efi" { print $1 }')"
	if [ ! -z "$rootcheck" ]; then
		array=(${array[@]/$drive/})
	fi
done
disk=${array[0]}
partition=${disk}1
sudo echo "label: gpt" | sudo sfdisk --force /dev/$disk
sudo echo ';' | sudo sfdisk --force /dev/$disk
echo "y" | sudo mkfs -t ext4 /dev/$partition
uuid="$(sudo blkid -s UUID -o value /dev/$partition)"
sudo mkdir /raid
echo "#Broadcom 9560 - /dev/$disk - added automatically via Puget Systems automation" | sudo tee -a /etc/fstab
echo "UUID=$uuid /raid ext4 defaults 0 0" | sudo tee -a /etc/fstab

###Network fix
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
echo '  renderer: networkd' | sudo tee -a /etc/netplan/01-netcfg.yaml
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

###GRUB fix
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="nomodeset amd-iommu=on iommu=pt pci=nommconf"/GRUB_CMDLINE_LINUX_DEFAULT="amd-iommu=on iommu=pt pci=nommconf"/' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=5/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=menu/g' /etc/default/grub
sudo update-grub

###Cleanup###
>~/.bash_history
rm ~/.bash_history >/dev/null 2>&1
rm -rf ~/.local/share/Trash/info/* >/dev/null 2>&1
rm -rf ~/.local/share/Trash/files/* >/dev/null 2>&1
rm -rf ~/Downloads/* >/dev/null 2>&1
sudo rm -rf /var/crash/* >/dev/null 2>&1
history -c
history -w
history -cw
>~/.bash_history
rm ~/.bash_history >/dev/null 2>&1
history -cw
sudo rm /$scriptname

###Reboot
sudo reboot
