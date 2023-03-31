#!/bin/bash
scriptname="client.sh"
clear

_viz_check() {
	if grep -q '"Vizgen, Inc."' ~/install/orderdata/orderdata; then
		if grep -q 'MA - Turn Key Solution' ~/install/orderdata/orderdata; then
			if [ ! -f ~/install/scripts/vizgen.sh ]; then
				_viz_assets
			fi
			if [ -f ~/install/scripts/vizgen.sh ]; then
				sudo sed -i '/~\/install/d' ~/.bashrc
				echo '~/install/scripts/vizgen.sh' >>~/.bashrc
			fi
		fi	
	fi
}

###Vizgen Turn-Key
_viz_assets() {
	clear
	echo 'Vizgen order detected. Credentials required to continue...'
	echo 'Please enter the username for the NAS'
	read -p "Username: " username
	clear
	echo 'Please enter the password for '$username
	read -p "Password: " password
	clear
	sudo mkdir -p /mnt/ntserver
	sudo mount -t cifs //172.17.0.10/production/Vizgen -o username=$username,password=$password /mnt/ntserver
	if [ -f /mnt/ntserver/vizgen.sh ]; then
		mkdir -p /home/$USER/install/assets/vizgen/analysis_configuration
		clear
		echo "Copying Vizgen assets..."
		echo
		sudo rsync -ah --progress /mnt/ntserver/vizgen.sh /home/$USER/install/scripts/vizgen.sh
		sudo rsync -ah --progress /mnt/ntserver/vizgen/update-package-232.zip /home/$USER/install/assets/vizgen/update-package-232.zip
		sudo rsync -ah --progress /mnt/ntserver/vizgen/analysis_configuration/* /home/$USER/install/assets/vizgen/analysis_configuration
		clear
		sudo chown -R $USER /home/$USER/install/assets/vizgen/analysis_configuration
		sudo chmod 777 /home/$USER/install/scripts/vizgen.sh
		sudo chmod 777 /home/$USER/install/assets/vizgen/analysis_configuration/*
		sudo chmod +x /home/$USER/install/scripts/vizgen.sh
		sudo umount /mnt/ntserver
		sudo rm -R /mnt/ntserver
	else
		while true; do
			clear
			echo 'Files not found. Would you like to try again? [Y/N]'
			read -p "" yn
			case $yn in
			[Yy]*)
				clear
				sudo umount /mnt/ntserver
				sudo rm -R /mnt/ntserver
				_viz_check
				break
				;;
			[Nn]*)
				clear
				break
				;;
			*) echo "Please answer yes or no." ;;
			esac
		done
	fi
}

