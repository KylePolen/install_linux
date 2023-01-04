#!/bin/bash
clear

scriptname="review.sh"
source ~/install/functions/global.sh
_os_check

if [ -f ~/install/reviewdata ]; then
	rm ~/install/reviewdata
fi
echo =============================================================================== >>~/install/reviewdata
echo ================================User/Host Name================================= >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
finger >>~/install/reviewdata
hostname >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo ==================================nvidia-smi=================================== >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
nvidia-smi >>~/install/reviewdata
echo >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo =====================================lsblk===================================== >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
lsblk >>~/install/reviewdata
echo >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo ====================================ifconfig=================================== >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
ifconfig -a >>~/install/reviewdata
echo >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo ====================================software=================================== >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
if test -f /opt/Adobe/Reader9/bin/acroread; then
	echo "Adobe Reader is installed" >>~/install/reviewdata
fi
if test -f /opt/google/chrome/chrome; then
	echo "Google Chrome is installed" >>~/install/reviewdata
fi
if test -f /etc/libreoffice/soffice.sh; then
	echo "Libre Office is installed" >>~/install/reviewdata
fi
if test -f /snap/bin/firefox; then
	echo "Mozilla Firefox is installed" >>~/install/reviewdata
fi
if test -f /usr/bin/vlc; then
	echo "Oracle VirtualBox is installed" >>~/install/reviewdata
fi
if test -f /usr/bin/vlc; then
	echo "VLC is installed" >>~/install/reviewdata
fi
#check to see if this is a Toyoata order
if grep -q '"company":"Toyota Research Institute"' ~/install/orderdata; then
	echo confirm that 64bit BAR support has been disabled on the NICs as per Toyota request.
	echo =============================================================================== >>~/install/reviewdata
	echo ===============================64bit BAR Disabled============================== >>~/install/reviewdata
	echo =============================================================================== >>~/install/reviewdata
	sudo ~/install/stuff/bootutil >>~/install/reviewdata
fi
less ~/install/reviewdata

#Writing Completion Flag
touch ~/install/flags/$scriptname
