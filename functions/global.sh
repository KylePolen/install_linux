#!/bin/bash
clear

###Get OS Type
_os_check() {
	kernelver=$(uname -r)
	if grep -q 20.04 /etc/os-release; then
		osversion="20.04"
		codename="focal"
	fi
	if grep -q 22.04 /etc/os-release; then
		osversion="22.04"
		codename="jammy"
	fi
	if grep -q 24.04 /etc/os-release; then
		osversion="24.04"
		codename="noble"
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
	dmiid=${serial:6:6}
	dmilength=${#dmiid}
	motherboard=$(sudo dmidecode -t 2 | grep -i 'Product Name: ') && motherboard=${motherboard:15}
}

###Count GPUs
GPUcount="$(lspci | awk '$2 == "VGA" { print $2 }')"
GPUarray=($GPUcount)

###Change ownership
_permissions() {
	if [ ! -f /home/$USER/install/orderdata/orderdata ]; then
		sudo chmod -R +x /home/$USER/install/*
		sudo chown -R $USER /home/$USER/install
		sudo chown -R $USER /home/$USER/install/.git*
	fi
}

###Get Order ID
_orderid() {
	if [ ! -f /home/$USER/install/flags/orderid ]; then
		if grep -q '[Pp]uget-' /etc/hostname; then
			orderid=${host/[Pp]uget-/} && orderid=${orderid:0:6}
		elif echo $serial | grep -q '[Pp]uget-'; then
			orderid=${serial/[Pp]uget-/} && orderid=${orderid:0:6}
		else
			clear
			echo 'Could not extract the orderid from the hostname, please enter order number.' \
				'If the system is part of a quantity please exclude the system number at the end.' | fold -s
			echo
			#if [ $dmilength == 6 ]; then
			#echo ''
			read -p "Order number: " orderid
			echo $orderid | sudo tee -a /home/$USER/install/flags/orderid
		fi
	else
		orderid=$(</home/$USER/install/flags/orderid)
	fi
}

###Get Order Data
_orderdata() {
	if [ -f /home/$USER/install/orderdata/orderdata ]; then
		sudo rm /home/$USER/install/orderdata/*
	fi
	wget -q -O - "https://admin.pugetsystems.com/admin/autoinstall/api.php?action=get_order_data&orderid=$orderid" >>/home/$USER/install/orderdata/orderdata
	if ! grep -q '"child_orders":null' ~/install/orderdata/orderdata; then
		sudo DEBIAN_FRONTEND=nointeractive apt install jq -y
		children=$(jq '.child_orders' ~/install/orderdata/orderdata | tr -d '"[],')
		childarray=($children)
		for i in "${childarray[@]}"; do
			wget -q -O - "https://admin.pugetsystems.com/admin/autoinstall/api.php?action=get_order_data&orderid=$i" >>/home/$USER/install/orderdata/$i
			cat ~/install/orderdata/$i >> ~/install/orderdata/orderdata
		done
	fi
}

###Delay Sleep Temporarily
_sleep() {
	if [ ! -f /home/$USER/install/flags/sleep ]; then
		if [ $ostype == "Desktop" ]; then
			sudo apt install dbus-x11 -y
			gsettings set org.gnome.desktop.session idle-delay 7200
			gsettings set org.gnome.desktop.screensaver lock-delay 7200
			touch /home/$USER/install/flags/sleep
		fi
	fi
}

###Puget Systems Branding
_branding() {
	if [ $ostype == "Desktop" ]; then
		ln -s /home/$USER/install /home/$USER/Desktop/install
		sudo cp /home/$USER/install/assets/Puget_Systems.png /usr/share/backgrounds/Puget_Systems.png
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
		sudo sed -i '$a user_pref("browser.startup.homepage", "https://www.pugetsystems.com/welcome/");' /home/$USER/.mozilla/firefox/*.default-release/prefs.js >/dev/null 2>&1
		sudo sed -i '$a user_pref("browser.startup.homepage", "https://www.pugetsystems.com/welcome/");' /home/$USER/.mozilla/firefox/*.default/prefs.js >/dev/null 2>&1
		sudo sed -i '$a user_pref("browser.startup.homepage", "https://www.pugetsystems.com/welcome/");' /home/$USER/snap/firefox/common/.mozilla/firefox/*.default/prefs.js >/dev/null 2>&1
	fi
}

_topbar() {
	x=80
	for i in $(seq 1 $x); do
		printf '=%.0s' >>~/install/reviewdata
	done
	echo "" >>~/install/reviewdata
}

_bottombar() {
	x=80
	for i in $(seq 1 $x); do
		printf '=%.0s' >>~/install/reviewdata
	done
	echo "" >>~/install/reviewdata
	echo "" >>~/install/reviewdata
}

_titlebar() {
	title_len=${#title}
	x=80
	x=$((x - title_len))
	x=$((x / 2))
	for i in $(seq 1 $x); do
		printf '=%.0s' >>~/install/reviewdata
	done
	test=$(tail -n 1 ~/install/reviewdata)
	if [ ${#test} == 79 ]; then printf '=' >>~/install/reviewdata; fi
	printf $title >>~/install/reviewdata
	for i in $(seq 1 $x); do
		printf '=%.0s' >>~/install/reviewdata
	done
	test=$(tail -n 1 ~/install/reviewdata)
	if [ ${#test} == 79 ]; then printf '=' >>~/install/reviewdata; fi
	echo "" >>~/install/reviewdata
}
