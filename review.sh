#!/bin/bash
clear

scriptname="review.sh"
source ~/install/functions/global.sh
_os_check

clear
echo 'Confirming you assigned the correct password. Default should be "Password1!"'

if [ -f ~/install/reviewdata ]; then
	rm ~/install/reviewdata
fi
echo =============================================================================== >>~/install/reviewdata
echo ================================User/Host Name================================= >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
hostname >>~/install/reviewdata
finger >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo ================================OS Information================================= >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo "Distro:" $osversion $ostype >>~/install/reviewdata
echo "Kernel:" $kernelver >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo ==================================nvidia-smi=================================== >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
if lspci -v | grep -q NVIDIA; then
	nvidia-smi >>~/install/reviewdata
else
	echo "An NVIDIA GPU was not detected in this system." >>~/install/reviewdata
fi
echo >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo =====================================lsblk===================================== >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
lsblk --noheadings | awk '$1 !~ "loop" && $1 != "sr0"' >>~/install/reviewdata
echo >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
echo ====================================ip brief=================================== >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
ip --brief address show >>~/install/reviewdata
echo >>~/install/reviewdata
if [ $ostype == "Server" ]; then
	echo =============================================================================== >>~/install/reviewdata
	echo ====================================netplan=================================== >>~/install/reviewdata
	echo =============================================================================== >>~/install/reviewdata
	cat /etc/netplan/01-netcfg.yaml >>~/install/reviewdata
	echo >>~/install/reviewdata
fi
if [ $ostype == "Desktop" ]; then
	echo =============================================================================== >>~/install/reviewdata
	echo ====================================software=================================== >>~/install/reviewdata
	echo =============================================================================== >>~/install/reviewdata
	if test -f /opt/Adobe/Reader9/bin/acroread; then
		echo "Adobe Reader is installed" >>~/install/reviewdata
	fi
	if test -f /opt/google/chrome/chrome; then
		echo "Google Chrome is installed" >>~/install/reviewdata
	fi
	if test -f /usr/lib/VirtualBox; then
		echo "Oracle VirtualBox is installed" >>~/install/reviewdata
	fi
	if test -f /usr/bin/vlc; then
		echo "VLC is installed" >>~/install/reviewdata
	fi
fi
#check to see if this is a Toyoata order
#if grep -q '"company":"Toyota Research' ~/install/orderdata/orderdata; then
#	echo confirm that 64bit BAR support has been disabled on the NICs as per Toyota request.
#	echo =============================================================================== >>~/install/reviewdata
#	echo ===============================64bit BAR Disabled============================== >>~/install/reviewdata
#	echo =============================================================================== >>~/install/reviewdata
#	sudo ~/install/assets/bootutil64e >>~/install/reviewdata
#fi
if grep -q '"Vizgen, Inc."' ~/install/orderdata/orderdata; then
echo =============================================================================== >>~/install/reviewdata
echo ==================================Merlin Check================================= >>~/install/reviewdata
echo =============================================================================== >>~/install/reviewdata
~/merlin_env/bin/merlin --version . >>~/install/reviewdata
fi
if [ $ostype == "Server" ]; then
	echo >>~/install/reviewdata
	echo >>~/install/reviewdata
	echo 'Press "q" to exit back to prompt' >>~/install/reviewdata
	less ~/install/reviewdata
else
gedit ~/install/reviewdata
fi

#Writing Completion Flag
touch ~/install/flags/$scriptname
