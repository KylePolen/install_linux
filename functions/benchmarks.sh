#!/bin/bash
scriptname="benchmarks.sh"

###AI Benchmarks
_ai_assets() {
	if grep -q 'Intel Xeon W790 5U' ~/install/orderdata/orderdata; then
		clear
		echo 'AI platform detected. Credentials required to continue...'
		echo 'Please enter the username for the NAS'
		read -p "Username: " username
		clear
		echo 'Please enter the password for '$username
		read -p "Password: " password
		clear
		sudo mkdir -p /mnt/ntserver
		sudo mount -t cifs //172.17.0.10/labs/Don -o username=$username,password=$password /mnt/ntserver
		if [ -f /mnt/ntserver/TGI-bench-0.2.tar ]; then
			mkdir -p /home/$USER/install/assets/ai
			clear
			echo "Copying AI Benchmark..."
			echo
			sudo rsync -ah --progress /mnt/ntserver/TGI-bench-0.2.tar /home/$USER/install/assets/ai/TGI-bench-0.2.tar
			clear
			sudo apt install -y unzip
			7z x /home/$USER/install/assets/ai/TGI-bench-0.2.tar -o/home/$USER/install/assets/ai
			chmod a+x /home/$USER/install/assets/ai/TGI-bench/*.sh
			ln -s /home/$USER/install/assets/ai/TGI-bench /home/$USER/Desktop/TGI-bench
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
					_ai_assets
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
	fi
}
