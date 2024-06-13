#!/bin/bash
clear

scriptname="review.sh"
source ~/install/functions/global.sh
_os_check && _hostdata && _orderid

clear
echo 'Confirming you assigned the correct password. Default should be "Password1!"'
echo ""
sudo clear

if [ -f ~/install/reviewdata ]; then rm ~/install/reviewdata; fi

title="User/Host Name"
_topbar
_titlebar
_bottombar
hostname >>~/install/reviewdata
finger >>~/install/reviewdata

title="OS Information"
_topbar
_titlebar
_bottombar
echo "Distro:" $osversion $ostype >>~/install/reviewdata
echo "Kernel:" $kernelver >>~/install/reviewdata

title="Motherboard Information"
_topbar
_titlebar
_bottombar
sudo dmidecode -t baseboard | awk '$1 == "Manufacturer:" { print$1" "$2" "$3" "$4" "$5" "$6" "$7}' >>~/install/reviewdata
sudo dmidecode -t baseboard | awk '$1 == "Product" { print$1" "$2" "$3" "$4" "$5" "$6" "$7}' >>~/install/reviewdata

title="BIOS Information"
_topbar
_titlebar
_bottombar
sudo dmidecode -t bios | awk '$1 == "Vendor:" { print$1" "$2" "$3" "$4" "$5" "$6" "$7}' >>~/install/reviewdata
sudo dmidecode -t bios | awk '$1 == "Version:" { print$1" "$2" "$3" "$4" "$5" "$6" "$7}' >>~/install/reviewdata
sudo dmidecode -t bios | awk '$1 == "Release" { print$1" "$2" "$3" "$4" "$5" "$6" "$7}' >>~/install/reviewdata

title="Processor Information"
_topbar
_titlebar
_bottombar
lscpu | grep -i "Model Name:" >>~/install/reviewdata
lscpu | grep -i "Socket(s):" >>~/install/reviewdata
lscpu | grep -i "Core(s) per socket:" >>~/install/reviewdata
lscpu | grep -i "Thread(s) per core:" >>~/install/reviewdata
lscpu | grep -i "CPU max MHz:" >>~/install/reviewdata
lscpu | grep -i "CPU min MHz:" >>~/install/reviewdata
lscpu | grep -i "BogoMIPS:" >>~/install/reviewdata

title="RAM Information"
_topbar
_titlebar
_bottombar
free -h >>~/install/reviewdata

if lspci -v | grep -q NVIDIA; then
	title="Display Information"
	_topbar
	_titlebar
	_bottombar
	nvidia-smi >>~/install/reviewdata
fi

title="Disk/Mount Information"
_topbar
_titlebar
_bottombar
lsblk --noheadings | awk '$1 !~ "loop" && $1 != "sr0"' >>~/install/reviewdata

title="Detected Network Controllers"
_topbar
_titlebar
_bottombar
#ip --brief address show | awk '$1 != "lo" {print $0}' >>~/install/reviewdata
lspci -q | grep -i net >>~/install/reviewdata

#if [ $ostype == "Server" ]; then
	title="Netplan Configuration"
	_topbar
	_titlebar
	_bottombar
	#cat /etc/netplan/01-netcfg.yaml >>~/install/reviewdata
	cat /etc/netplan/01-* >>~/install/reviewdata
#fi

if grep -q '"category": "Software: Courtesy Install",' ~/install/orderdata/orderdata; then
	title="Courtesy Software"
	_topbar
	_titlebar
	_bottombar
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

if [ $ostype == "Server" ]; then
	echo >>~/install/reviewdata
	echo >>~/install/reviewdata
	echo 'Press "q" to exit back to prompt' >>~/install/reviewdata
	less ~/install/reviewdata
	sudo sed -i '$ d' ~/install/reviewdata
else
	gedit ~/install/reviewdata
fi
exit
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
sudo cp ~/install/reviewdata /mnt/ntserver/linux_review/$host.txt
sudo umount /mnt/ntserver
sudo rm -R /mnt/ntserver

#Writing Completion Flag
touch ~/install/flags/$scriptname
