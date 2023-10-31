#!/bin/bash
scriptname="benchmarks.sh"

###AI Benchmarks
_ai_assets_full() {
	if grep -q '"comments": "Accelerator"' ~/install/orderdata/orderdata; then
		if grep -q 'Intel Xeon W790 5U' ~/install/orderdata/orderdata; then
			if grep -q '"ai server"' ~/install/orderdata/orderdata; then
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
				if [ -f /mnt/ntserver/TGI-bench-0.3.tar ]; then
					curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg &&
						curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
						sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' |
							sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list &&
						sudo apt-get update
					sudo apt-get install -y nvidia-container-toolkit
					sudo apt-get install -y unzip
					mkdir -p /home/$USER/install/assets/ai
					clear
					echo "Copying AI Benchmark..."
					echo
					rsync -ah --progress /mnt/ntserver/TGI-bench-0.3.tar /home/$USER/install/assets/ai/TGI-bench-0.3.tar
					wget -O ~/install/assets/ai/TGI-bench-main.zip https://github.com/dbkinghorn/TGI-bench/archive/refs/heads/main.zip
					clear
					sudo apt install -y pv
					clear
					echo "Extracting AI Benchmark..."
					echo
					pv /home/$USER/install/assets/ai/TGI-bench-0.3.tar | tar -xC /home/$USER/install/assets/ai
					unzip -o /home/$USER/install/assets/ai/TGI-bench-main.zip -d /home/$USER/install/assets/ai
					cp -R -f /home/$USER/install/assets/ai/TGI-bench-main/* -t /home/$USER/install/assets/ai/TGI-bench
					if [ "$ostype" == "Desktop" ]; then
						ln -s /home/$USER/install/assets/ai/TGI-bench /home/$USER/Desktop/TGI-bench
					fi
					echo '#!/bin/bash' >>/home/$USER/install/AI_RUN.sh
					echo 'sudo clear' >>/home/$USER/install/AI_RUN.sh
					echo 'cd /home/$USER/install/assets/ai/TGI-bench' >>/home/$USER/install/AI_RUN.sh
					echo './RUN-ME-4x6000Ada 30' >>/home/$USER/install/AI_RUN.sh
					echo 'clear' >>/home/$USER/install/AI_RUN.sh
					echo 'sudo mkdir -p /mnt/ntserver' >>/home/$USER/install/AI_RUN.sh
					echo "sudo mount -t cifs //172.17.0.10/scratch/AI -o username=$username,password=$password /mnt/ntserver" >>/home/$USER/install/AI_RUN.sh
					echo 'until [ -f /home/$USER/install/assets/ai/TGI-bench/summary.out ]' >>/home/$USER/install/AI_RUN.sh
					echo 'do' >>/home/$USER/install/AI_RUN.sh
					echo '	sleep 5' >>/home/$USER/install/AI_RUN.sh
					echo 'done' >>/home/$USER/install/AI_RUN.sh
					echo "sudo cp -f /home/$USER/install/assets/ai/TGI-bench/summary.out /mnt/ntserver/$(hostname).txt" >>/home/$USER/install/AI_RUN.sh
					echo 'sudo umount /mnt/ntserver' >>/home/$USER/install/AI_RUN.sh
					echo 'sudo rm -R /mnt/ntserver' >>/home/$USER/install/AI_RUN.sh
					sudo chmod +x /home/$USER/install/AI_RUN.sh
					sudo umount /mnt/ntserver
					sudo rm -R /mnt/ntserver
					if [ $ostype == "Server" ]; then
						if grep -q 'Gnome Desktop Installation' ~/install/orderdata/orderdata; then
							sudo apt install lightdm ubuntu-dekstop -y
						fi
					fi
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
		fi
	fi	
}

_ai_assets_small() {
	if ! grep -q '"comments": "Accelerator"' ~/install/orderdata/orderdata; then
		if grep -q 'Intel Xeon W790 5U' ~/install/orderdata/orderdata; then
			if grep -q '"ai server"' ~/install/orderdata/orderdata; then
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
				if [ -f /mnt/ntserver/TGI-bench-0.3.tar ]; then
					curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg &&
						curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
						sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' |
							sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list &&
						sudo apt-get update
					sudo apt-get install -y nvidia-container-toolkit
					sudo apt-get install -y unzip
					mkdir -p /home/$USER/install/assets/ai
					clear
					echo "Copying AI Benchmark..."
					echo
					rsync -ah --progress /mnt/ntserver/TGI-bench-small.tar /home/$USER/install/assets/ai/TGI-bench-small.tar
					clear
					sudo apt install -y pv
					clear
					echo "Extracting AI Benchmark..."
					echo
					pv /home/$USER/install/assets/ai/TGI-bench-small.tar | tar -xC /home/$USER/install/assets/ai
					if [ "$ostype" == "Desktop" ]; then
						ln -s /home/$USER/install/assets/ai/TGI-bench-small /home/$USER/Desktop/TGI-bench-small
					fi
					echo '#!/bin/bash' >>/home/$USER/install/AI_RUN.sh
					echo 'sudo clear' >>/home/$USER/install/AI_RUN.sh
					echo 'cd /home/$USER/install/assets/ai/TGI-bench-small' >>/home/$USER/install/AI_RUN.sh
					echo './RUN-ME-1x16GB-GPU 30' >>/home/$USER/install/AI_RUN.sh
					echo 'clear' >>/home/$USER/install/AI_RUN.sh
					echo 'sudo mkdir -p /mnt/ntserver' >>/home/$USER/install/AI_RUN.sh
					echo "sudo mount -t cifs //172.17.0.10/scratch/AI -o username=$username,password=$password /mnt/ntserver" >>/home/$USER/install/AI_RUN.sh
					echo 'until [ -f /home/$USER/install/assets/ai/TGI-bench-small/summary.out ]' >>/home/$USER/install/AI_RUN.sh
					echo 'do' >>/home/$USER/install/AI_RUN.sh
					echo '	sleep 5' >>/home/$USER/install/AI_RUN.sh
					echo 'done' >>/home/$USER/install/AI_RUN.sh
					echo "sudo cp -f /home/$USER/install/assets/ai/TGI-bench-small/summary.out /mnt/ntserver/$(hostname).txt" >>/home/$USER/install/AI_RUN.sh
					echo 'sudo umount /mnt/ntserver' >>/home/$USER/install/AI_RUN.sh
					echo 'sudo rm -R /mnt/ntserver' >>/home/$USER/install/AI_RUN.sh
					sudo chmod +x /home/$USER/install/AI_RUN.sh
					sudo umount /mnt/ntserver
					sudo rm -R /mnt/ntserver
					if [ $ostype == "Server" ]; then
						if grep -q 'Gnome Desktop Installation' ~/install/orderdata/orderdata; then
							sudo apt install lightdm ubuntu-dekstop -y
						fi
					fi
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
		fi
	fi	
}
