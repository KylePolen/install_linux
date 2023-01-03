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

_os_check
_hostdata
_permissions
_orderid
_orderdata
