#!/bin/bash
scriptname=master.sh
clear

source ~/install/functions/global.sh
source ~/install/functions/fixes.sh

echo "sourced"
read -p ""

~/install/functions/branding.sh
echo "branding"
read -p ""
~/install/scripts/intel_display.sh
echo "intdis"
read -p ""
~/install/scripts/highpoint.sh
echo "hp"
read -p ""
~/install/functions/drivers.sh
echo "drivers"
read -p ""
~/install/functions/software.sh
echo "software"
read -p ""
~/install/functions/updates.sh
echo "updates"
read -p ""
~/install/scripts/mount.sh
echo "mount"
read -p ""
~/install/functions/fixes.sh
echo "fixes"
read -p ""

#Stop autorun
_os_check
if [ $ostype == "Server" ]; then
	sudo sed -i '/~\/install/d' ~/.bashrc
else
	sudo rm /etc/profile.d/$scriptname
fi

sudo shutdown -r now
