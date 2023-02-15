#!/bin/bash
clear

###Get OS Type
_os_check() {
	if grep -q 22.04 /etc/os-release; then
		osversion="22.04"
		codename="jammy"
	else
		osversion="20.04"
		codename="focal"
	fi
	if grep -q Server /var/log/installer/media-info; then
		ostype="Server"
	else
		ostype="Desktop"
	fi
}

###Define Variables
_hostdata() {
	host=$(hostname)
	serial=$(sudo dmidecode -t 1 | grep -i 'Serial Number: ') && serial=${serial:15}
	motherboard=$(sudo dmidecode -t 2 | grep -i 'Product Name: ') && motherboard=${motherboard:15}
}

###Change ownership
_permissions() {
	if [ ! -f ~/install/orderdata ]; then
		sudo chmod -R +x ~/install/*
		sudo chown -R $USER ~/install
		sudo chown -R $USER ~/install/.git*
	fi
}

###Get Order ID
_orderid() {
	if [ ! -f ~/install/flags/orderid ]; then
		if grep -q '[Pp]uget-' /etc/hostname; then
			orderid=${host/[Pp]uget-/} && orderid=${orderid:0:6}
		elif echo $serial | grep -q '[Pp]uget-'; then
			orderid=${serial/[Pp]uget-/} && orderid=${orderid:0:6}
		else
			clear
			echo 'Could not extract the orderid from the hostname, please enter order number.' \
				'If the system is part of a quantity please exclude the system number at the end.' | fold -s
			echo
			read -p "Order number: " orderid
			echo $orderid | sudo tee -a ~/install/flags/orderid
		fi
	else
		orderid=$(<~/install/flags/orderid)
	fi
}

###Get Order Data
_orderdata() {
	if [ -f ~/install/orderdata ]; then
		sudo rm ~/install/orderdata
	fi
	wget -q -O - "https://admin.pugetsystems.com/admin/autoinstall/api.php?action=get_order_data&orderid=$orderid" >>~/install/orderdata
}

###Delay Sleep Temporarily
_sleep() {
	if [ ! -f ~/install/flags/sleep ]; then
		if [ $ostype == "Desktop" ]; then
			sudo apt install dbus-x11 -y
			gsettings set org.gnome.desktop.session idle-delay 7200
			gsettings set org.gnome.desktop.screensaver lock-delay 7200
			touch ~/install/flags/sleep
		fi
	fi
}

###Puget Systems Branding
_branding() {
	if [ $ostype == "Desktop" ]; then
		ln -s ~/install ~/Desktop/install
		sudo cp ~/install/assets/Puget_Systems.png /usr/share/backgrounds/Puget_Systems.png
		sudo chown user /usr/share/backgrounds/Puget_Systems.png
		sudo chmod 777 /usr/share/backgrounds/Puget_Systems.png
		gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/Puget_Systems.png
		gsettings set org.gnome.desktop.screensaver picture-uri file:///usr/share/backgrounds/Puget_Systems.png
		if [ $osversion == "22.04" ]; then
			gsettings set org.gnome.shell.extensions.ding show-home false
		fi
		if [ $osversion == "20.04" ]; then
			gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
		fi
		#Firefox Puget Branding
		firefox --headless >/dev/null 2>&1 &
		sleep 5
		pkill -f firefox
		wait
		sudo sed -i '$a user_pref("browser.startup.homepage", "https://account.pugetsystems.com/welcome.php?oid='$orderid'");' ~/.mozilla/firefox/*.default-release/prefs.js >/dev/null 2>&1
		sudo sed -i '$a user_pref("browser.startup.homepage", "https://account.pugetsystems.com/welcome.php?oid='$orderid'");' ~/.mozilla/firefox/*.default/prefs.js >/dev/null 2>&1
		sudo sed -i '$a user_pref("browser.startup.homepage", "https://account.pugetsystems.com/welcome.php?oid='$orderid'");' ~/snap/firefox/common/.mozilla/firefox/*.default/prefs.js >/dev/null 2>&1
	fi
}

###Vizgen Turn-Key
_viz_check() {
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
		mkdir -p ~/install/assets/vizgen/analysis_configuration
		echo "Copying Vizgen assets..."
		sudo cp /mnt/ntserver/vizgen.sh ~/install/scripts/vizgen.sh
		sudo cp /mnt/ntserver/vizgen/update-package-232.zip ~/install/assets/vizgen/update-package-232.zip
		sudo cp -R /mnt/ntserver/vizgen/analysis_configuration/* ~/install/assets/vizgen/analysis_configuration
		sudo chown -R $USER ~/install/assets/vizgen/analysis_configuration
		sudo chmod 777 ~/install/scripts/vizgen.sh
		sudo chmod 777 ~/install/assets/vizgen/analysis_configuration/*
		sudo chmod +x ~/install/scripts/vizgen.sh
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
