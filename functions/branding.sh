#!/bin/bash
scriptname="branding.sh"
clear

if [ -f ~/install/flags/$scriptname ]; then
	exit
fi

source ~/install/functions/global.sh

#Delay Sleep Temporarily
_sleep() {
	_os_check
	if [ ! -f ~/install/flags/sleep ]; then
		if [ $ostype == "Desktop" ]; then
			sudo apt install dbus-x11 -y
			gsettings set org.gnome.desktop.session idle-delay 7200
			gsettings set org.gnome.desktop.screensaver lock-delay 7200
			touch ~/install/flags/sleep
		fi
	fi
}

#OS Puget Branding
_branding() {
	_os_check
	_orderid
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

_sleep
_branding

#Writing Completion Flag
touch ~/install/flags/$scriptname
