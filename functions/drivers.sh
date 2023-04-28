#!/bin/bash
scriptname="drivers.sh"
clear

#NVIDIA
_nvidia() {
	if lspci -v | grep -q NVIDIA; then
		sudo DEBIAN_FRONTEND=nointeractive add-apt-repository -y ppa:graphics-drivers/ppa
		sudo apt update
		if [ "$ostype" == "Desktop" ]; then
			sudo DEBIAN_FRONTEND=nointeractive apt -y install nvidia-driver-530
		else
			sudo DEBIAN_FRONTEND=nointeractive apt -y install nvidia-driver-530 --no-install-recommends
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

#Highpoint 7505
_hp7505() {
if lspci -v | grep -q '7505\|SSD7505'; then
	if grep -q 'RAID Setup (Add-In Controller)' ~/install/orderdata/orderdata; then
		if [ ! -f /etc/init.d/hptdrv-monitor ]; then
			clear
			echo 'Highpoint 7505 detected. The system will reboot after installing drivers.'
			echo 'The script will automatically restart once you log back in.'
			echo 'Press any key to continue.'
			read -p ""
			cd ~/install/assets
			wget -c https://github.com/KylePolen/install_linux/raw/main/assets/drivers/hp7505/hptnvme_g5_linux_src_v1.4.1_2022_03_04.bin
			wget -c https://github.com/KylePolen/install_linux/raw/main/assets/drivers/hp7505/RAID_Manage_Linux_v3.1.5_22_06_10.bin
			sudo chmod +x *.bin
			sudo ./hptnvme_g5_linux_src_v1.4.1_2022_03_04.bin
			sudo ./RAID_Manage_Linux_v3.1.5_22_06_10.bin
			sleep 5
			if [ "$motherboard" == "X299 AORUS Gaming 7" ]; then
				sudo sed -i 's/ iommu=off//' /etc/default/grub
				sudo sed -i 's/GRUB_CMDLINE_LINUX="iommu=off /GRUB_CMDLINE_LINUX="/' /etc/default/grub
				sudo update-grub
			fi
			if [ $ostype == "Server" ]; then
				sudo sed -i '/~\/install/d' ~/.bashrc
				echo '~/install/master.sh' >>~/.bashrc
			else
				sudo rm /etc/profile/.d/master.sh
				echo "sleep 5" | sudo tee -a /etc/profile.d/master.sh
				echo 'gnome-terminal -- ~/install/master.sh' | sudo tee -a /etc/profile.d/master.sh
			fi
			sudo reboot
			exit
		fi
	fi	
fi
}

#Highpoint 640L
_hp640L() {
if lspci -v | grep -q '640L 4 Port'; then
	if [ ! -f /etc/init.d/hptdrv-monitor ]; then
		clear
		echo 'Highpoint 640L detected. The system will reboot after installing drivers.'
		echo 'The script will automatically restart once you log back in.'
		read -p ""
		cd ~/install/assets
		wget -c https://github.com/KylePolen/install_linux/raw/main/assets/drivers/hp640L/rr64xl-linux_x86_64_src_v1.6.7_22_11_28.bin
		wget -c https://github.com/KylePolen/install_linux/raw/main/assets/drivers/hp640L/RAID_Manage_Linux_v3.1.5_22_06_10.bin
		sudo chmod +x *.bin
		sudo ./rr64xl-linux_x86_64_src_v1.6.7_22_11_28.bin
		sudo ./RAID_Manage_Linux_v3.1.5_22_06_10.bin
		sleep 5
		if [ "$motherboard" == "X299 AORUS Gaming 7" ]; then
			sudo sed -i 's/ iommu=off//' /etc/default/grub
			sudo update-grub
		fi
		if [ $ostype == "Server" ]; then
			sudo sed -i '/~\/install/d' ~/.bashrc
			echo '~/install/master.sh' >>~/.bashrc
		else
			sudo rm /etc/profile/.d/master.sh
			echo "sleep 5" | sudo tee -a /etc/profile.d/master.sh
			echo 'gnome-terminal -- ~/install/master.sh' | sudo tee -a /etc/profile.d/master.sh
		fi
		sudo reboot
		exit
	fi
fi
}
