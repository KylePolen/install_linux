#!/bin/bash
scriptname="mount.sh"
clear

#Dependant on $drivemount
_mount() {
	clear
	echo 'Please specify the absolute path you would like to use as a mount point.'
	echo 'If the path is left blank, the default path will be used.'
	echo 'The default path for this drive is /'$drivemount
	echo
	mount="placehold"
	until [ -d $mount ]; do
		read -e -p "Mount path: " -i '/'$drivemount mount
		clear
		#Checks for illegal characters
		if [[ $mount == *['!'@#\$%^\&*_+]* ]]; then
			clear
			echo $mount 'contains invalid characters. Press any key to try again.'
			read -p ""
			clear
			_mount
		fi
		#Checks and corrects mount path
		if [ "${mount:0:1}" != "/" ]; then
			mount="/""$mount"
		fi
		#Default
		if [ "$mount" == "/" ]; then
			mount="/""$drivemount"
		fi
		#Mount point already exists
		if [ -d $mount ]; then
			clear
			echo $mount 'already exists, continue or retry? Enter "continue" to keep going (not recommended) or any key to retry.'
			read -p "Selection: " retry
			echo
			case $retry in
			[Cc]ontinue) break ;;
			*)
				clear
				_mount
				;;
			esac
		fi
		if [ ! -d $mount ]; then
			sudo mkdir $mount
		fi
	done
}

#Dependant on $drive and $partition
_format() {
	sudo echo "label: gpt" | sudo sfdisk --force /dev/$drive
	sudo echo ';' | sudo sfdisk --force /dev/$drive
	echo "y" | sudo mkfs -t ext4 /dev/$partition
	uuid="$(sudo blkid -s UUID -o value /dev/$partition)"
	echo "#$drivename - /dev/$drive - added by Puget Systems" | sudo tee -a /etc/fstab
	echo "UUID=$uuid $mount ext4 defaults 0 0" | sudo tee -a /etc/fstab
}

#Main array
sudo DEBIAN_FRONTEND=nointeractive apt install smartmontools -y
clear
drive="$(lsblk --noheadings -d -o NAME,TYPE,STATE,VENDOR | awk '$2 == "disk" { print $1 }')"
array=($drive)

#Make sure root drive is removed from array
for drive in "${array[@]}"; do
	rootcheck="$(lsblk --noheadings /dev/$drive -o NAME,MOUNTPOINT | awk '$2 == "/boot/efi" { print $1 }')"
	if [ ! -z "$rootcheck" ]; then
		array=(${array[@]/$drive/})
	fi
done

#Start main run
if [ "${#array[@]}" -gt "0" ]; then
	s=""
	h=""
	n=""
	r=""
	for drive in "${array[@]}"; do
		case "$drive" in 'sd'*)
			drivecheck="$(sudo smartctl -a /dev/$drive | awk -F':' '/rpm/ { print $2 }' | xargs)"
			raidcheck="$(sudo smartctl -a /dev/$drive | awk -F':' '/AVAGO/ { print $2 }' | xargs)"
			adapteccheck="$(sudo smartctl -a /dev/$drive | awk -F':' '/ASR8405/ { print $2 }' | xargs)"
			if [ -z "$drivecheck" ]; then
				if [ "$raidcheck" == "AVAGO" -o "$adapteccheck" == "ASR8405" ]; then
					drivemount="raid"$r
					partition="$drive""1"
					r=$(($r + 1))
				else
					drivemount="ssd"$s
					partition="$drive""1"
					s=$(($s + 1))
				fi
			else
				drivemount="hdd"$h
				partition="$drive""1"
				h=$(($h + 1))
			fi
			;;
		esac
		case "$drive" in 'nvme'*)
			drivemount="nvme"$n
			partition="$drive""p1"
			n=$(($n + 1))
			;;
		esac
		while true; do
			sudo clear
			drivename="$(sudo smartctl -a /dev/$drive | awk -F':' '/Device Model/ { print $2 }' | xargs)"
			if [ -z "$drivename" ]; then
				drivename="$(sudo smartctl -a /dev/$drive | awk -F':' '/Model Number/ { print $2 }' | xargs)"
				if [ -z "$drivename" ]; then
					drivename="$(sudo smartctl -a /dev/$drive | awk -F':' '/Vendor/ { print $2 }' | xargs)"
				fi
			fi
			driveserial="$(sudo smartctl -a /dev/$drive | awk -F':' '/Serial Number/ { print $2 }' | xargs)"
			echo $drivename '('$drive')' '('$driveserial')'
			echo 'is ready for formatting and mounting.'
			echo 'Do you wish to continue? [Y/N]'
			read -p "" yn
			case $yn in
			[Yy]*)
				clear
				_mount
				_format
				break
				;;
			[Nn]*)
				clear
				break
				;;
			*) echo "Please answer yes or no." ;;
			esac
		done
	done
fi

