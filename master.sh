#!/bin/bash
scriptname=master.sh
clear

source ~/install/functions/global.sh
source ~/install/functions/fixes.sh

~/install/functions/branding.sh
~/install/scripts/intel_display.sh
~/install/scripts/highpoint.sh
~/install/functions/drivers.sh
~/install/functions/software.sh
~/install/functions/updates.sh
~/install/scripts/mount.sh
~/install/functions/fixes.sh

#Stop autorun
_os_check
if [ $ostype == "Server" ]; then
	sudo sed -i '/~\/install/d' ~/.bashrc
else
	sudo rm /etc/profile.d/$scriptname
fi

sudo shutdown -r now
