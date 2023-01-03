#!/bin/bash
clear
#Self Contained
_arraytype() {
	while true; do
		clear
		echo 'This tool is designed to use all detected drives on the highpoint controller.'
		echo 'For more control, please configure the array manually.'
		echo 'http://localhost:7402'
		echo
		echo 'Please select the array type you would like to build. 0, 1, 10'
		read -p "Array Type: " arraytype
		case $arraytype in
		0)
			arraytype="RAID0"
			break
			;;
		1)
			arraytype="RAID1"
			break
			;;
		10)
			arraytype="RAID10"
			break
			;;
		*)
			clear && echo $arraytype 'is an invalid selection.'
			read -p "Press any key to continue..."
			;;
		esac
	done
}

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

#Broken
_unmount() {
	uuidcheck="$(sudo blkid -s UUID -o value /dev/hptblock0n0p*)"
	uuidcheck="UUID=""$uuidcheck"
	if grep -q $uuidcheck /etc/fstab; then
		fstab_entry="$(grep -w $uuidcheck /etc/fstab)"
		fstab_line="$(grep -n $uuidcheck /etc/fstab | cut -d : -f 1)"
		mountpoint="$(echo $fstab_entry | grep -oP '(?<=/).*(?=ext4)')"
		mountpoint="/""$mountpoint"
		clear
		echo "There is currently a RAID already mounted at $mountpoint"
		echo "Press any key to unmount the array and clear the fstab entry."
		read -p ""
		clear
		sudo umount /dev/hptblock0n0p*
		sudo sed -i $fstab_line'd' /etc/fstab
		sudo rm -r $mountpoint
	fi
}
