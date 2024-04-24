#!/bin/bash
clear

scriptname="review.sh"
source ~/install/functions/global.sh
_os_check
_hostdata
_orderid

clear
echo 'Confirming you assigned the correct password. Default should be "Password1!"'
echo ""
sudo clear

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
if [ ! -f ~/install/orderdata/orderdata ]; then
	touch ~/install/orderdata/orderdata
fi
#if grep -q '"Vizgen, Inc."' ~/install/orderdata/orderdata; then
#	echo =============================================================================== >>~/install/reviewdata
#	echo ==================================Merlin Check================================= >>~/install/reviewdata
#	echo =============================================================================== >>~/install/reviewdata
#	~/merlin_env/bin/merlin --version . >>~/install/reviewdata
#fi




if [ $ostype == "Server" ]; then
	echo >>~/install/reviewdata
	echo >>~/install/reviewdata
	echo 'Press "q" to exit back to prompt' >>~/install/reviewdata
	less ~/install/reviewdata
else
	gedit ~/install/reviewdata
fi

clear
echo 'Uploading results to the NAS...'
echo 'Please enter the username for the NAS'
read -p "Username: " username
clear
echo 'Please enter the password for '$username
read -p "Password: " password
clear
sudo mkdir -p /mnt/ntserver
sudo mount -t cifs //172.17.0.10/scratch -o username=$username,password=$password /mnt/ntserver
sudo chown $USER /mnt/ntserver
sudo cp ~/install/reviewdata /mnt/ntserver/linux_review/$orderid.txt
sudo umount /mnt/ntserver
sudo rm -R /mnt/ntserver

#Writing Completion Flag
touch ~/install/flags/$scriptname
