#!/bin/bash
scriptname=master.sh
clear

###Source all functions
for i in ~/install/functions/*;
  do source $i
done

###Needed for all systems
_os_check #Server vs. Desktop, 20.04 vs. 22.04
_hostdata #Hostname and DMI
_permissions #Ownership and execution
_orderid #Order number from _hostdata
_orderdata #Get order JSON
_sleep #Disables sleep until cleanup is ran
_branding #Puget Systems branding

#~/install/scripts/intel_display.sh
#~/install/scripts/highpoint.sh

###Display Drivers
_nvidia
_amdigpu
_aspeed

###Courtesy Software
if [ $ostype == "Desktop" ]; then
	_soft_virtualbox
	_soft_chrome
	_soft_reader
	_soft_vlc
fi

###Install additional packages and updates
_update_desktop
_update_server

###Script for additional drive mounting
~/install/scripts/mount.sh

#VizCheck
if grep -q '"Vizgen, Inc."' ~/install/orderdata; then
	if [ ! -f ~/install/scripts/vizgen.sh ]; then
		_viz_check
	fi
	if [ -f ~/install/scripts/vizgen.sh ]; then
		echo '~/install/scripts/vizgen.sh' >>~/.bashrc
	fi
fi

###GRUB and network fixes
_mobofix
_toyota
_netman

#Stop autorun
if [ ! -f ~/install/scripts/vizgen.sh ]; then
	if [ $ostype == "Server" ]; then
		sudo sed -i '/~\/install/d' ~/.bashrc
	else
		sudo rm /etc/profile.d/$scriptname
	fi
fi

sudo shutdown -r now
