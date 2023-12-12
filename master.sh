#!/bin/bash
scriptname=master.sh
clear

###Source all functions
for i in ~/install/functions/*;
  do source $i
done

###############################################################
####################### GLOBAL FUNCTIONS ######################
## _os_check - Server vs. Desktop, 20.04 vs. 22.04			
## _hostdata - Hostname and motherboard model from DMI
## _permissions - Ownership and execution of install folder
## _orderid - Order number from _hostdata/prompt
## _orderdata - Get Parent and Child order JSONs
## _sleep - Disables sleep until cleanup is ran
## _branding - Puget Systems branding
###############################################################
###############################################################
###Needed for all systems
_os_check
_hostdata
_permissions
_orderid
_orderdata
_viz_os_heck
_sleep
_branding

###Drivers requiring reboot
_hp7505
_hp640L
_hp3720c

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

#Clients
#_viz_check

#Benchmarks
#_ai_assets_small
#_ai_assets_full

###GRUB and network fixes
_mobofix
_toyota
_netman
_grubtime

#Stop autorun
if [ ! -f ~/install/scripts/vizgen.sh ]; then
	if [ $ostype == "Server" ]; then
		sudo sed -i '/~\/install/d' ~/.bashrc
	else
		sudo rm /etc/profile.d/master.sh
	fi
fi

sudo shutdown -r now
