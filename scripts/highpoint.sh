#!/bin/bash
scriptname="highpoint.sh"
clear

if [ -f ~/install/flags/$scriptname ]; then
	exit
fi

source ~/install/functions/disk_functions.sh
source ~/install/functions/global.sh

_hostdata
_os_check

#MAIN RUN
if lspci -v | grep -q '7505\|SSD7505'; then
	if [ ! -f /etc/init.d/hptdrv-monitor ]; then
		cd ~/install/assets
		wget -c https://github.com/KylePolen/install_linux/raw/main/assets/drivers/hptnvme_g5_linux_src_v1.4.1_2022_03_04.bin
		wget -c https://github.com/KylePolen/install_linux/raw/main/assets/drivers/RAID_Manage_Linux_v3.1.5_22_06_10.bin
		sudo chmod +x *.bin
		sudo ./hptnvme_g5_linux_src_v1.4.1_2022_03_04.bin
		sudo ./RAID_Manage_Linux_v3.1.5_22_06_10.bin
		sleep 5
		if [ "$motherboard" == "X299 AORUS Gaming 7" ]; then
			sudo sed -i 's/ iommu=off//' /etc/default/grub
			sudo update-grub
		fi
		touch ~/install/flags/hp_flag
		if [ $ostype == "Server" ]; then
			sudo sed -i '/~\/install/d' ~/.bashrc
			echo '~/install/functions/'$scriptname'' >>~/.bashrc
		else
			sudo rm /etc/profile/.d/master.sh
			echo "sleep 5" | sudo tee -a /etc/profile.d/$scriptname
			echo 'gnome-terminal -- ~/install/functions/'$scriptname'' | sudo tee -a /etc/profile.d/$scriptname
		fi
		clear
		echo 'The system will automatically reboot 3 times during the setup process. please read the instructions carefully.'
		echo 'Press any key to reboot the system.'
		read -p ""
		sudo reboot
		exit
	fi
else
	touch ~/install/flags/$scriptname
	exit
fi

###Highpoint Config Step 1
if [ -f ~/install/flags/hp_flag ]; then
	clear
	echo 'Do you wish to continue setting up the highpoint RAID array?'
	echo 'ALL DATA WILL BE DESTROYED! [Y/N]'
	while true; do
		read -p "" yn
		case $yn in
		[Yy]*)
			clear
			_arraytype
			echo $arraytype | tee -a ~/install/flags/arraytype
			query=$(sudo hptraidconf -u RAID -p hpt query arrays)
			while [[ $query = *1* ]]; do
				sudo hptraidconf -u RAID -p hpt delete 1
				query=$(sudo hptraidconf -u RAID -p hpt query arrays)
			done
			rm ~/install/flags/hp_flag
			touch ~/install/flags/hp_flag1
			reboot
			;;
		[Nn]*)
			clear
			rm ~/install/flags/hp_flag
			touch ~/install/flags/$scriptname
			exit
			;;
		*)
			clear
			echo "INVALID SELECTION"
			echo
			echo 'Do you wish to continue setting up the highpoint RAID array? [Y/N]'
			echo 'ALL DATA WILL BE DESTROYED! [Y/N]'
			;;
		esac
	done
fi

###Highpoint Config Step 2
if [ -f ~/install/flags/hp_flag1 ]; then
	n=1
	arraytype=$(<~/install/flags/arraytype)
	legacy=$(sudo hptraidconf -u RAID -p hpt query devices)
	while [[ $legacy = *LEGACY* ]]; do
		sudo hptraidconf -u RAID -p hpt init 1/E1/$n
		legacy=$(sudo hptraidconf -u RAID -p hpt query devices)
		n=$(($n + 1))
	done
	if [ "$arraytype" != "RAID1" ]; then
		sudo hptraidconf -u RAID -p hpt create $arraytype disks='*' name="'$arraytype'"
	else
		sudo hptraidconf -u RAID -p hpt create $arraytype disks=1/E1/1,1/E1/2 bs=512k sector=512b init=quickinit name="'$arraytype'"
	fi
	sleep 2
	rm ~/install/flags/hp_flag1
	rm ~/install/flags/arraytype
	if [ $ostype == "Server" ]; then
		sudo sed -i '/'$scriptname'/d' ~/.bashrc
		echo '~/install/master.sh' >>~/.bashrc
	else
		sudo rm /etc/profile.d/$scriptname
		echo "sleep 5" | sudo tee -a /etc/profile.d/master.sh
		echo 'gnome-terminal -- ~/install/master.sh' | sudo tee -a /etc/profile.d/master.sh
	fi
	clear
	echo 'RAID array setup is now complete. The system will reboot and begin the main setup script again.'
	echo 'The array will be mounted during that time. Press any key to continue.'
	read -p ""
	#Writing Completion Flag
	touch ~/install/flags/$scriptname
	reboot
fi
