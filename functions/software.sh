#!/bin/bash
scriptname="software.sh"
clear

#Oracle VirtualBox
_soft_virtualbox() {
	if grep -q '"name":"VirtualBox"' ~/install/orderdata; then
		sudo DEBIAN_FRONTEND=nointeractive apt install virtualbox -y
	fi
}

#Google Chrome
_soft_chrome() {
	if grep -q '"name":"Chrome"' ~/install/orderdata; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i google-chrome-stable_current_amd64.deb
		sudo rm -r google-chrome-stable*
	fi
}

#Adobe Reader
_soft_reader() {
	if grep -q '"name":"Acrobat Reader"' ~/install/orderdata; then
		sudo dpkg --add-architecture i386
		sudo sudo DEBIAN_FRONTEND=nointeractive apt install libxml2:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libatk-adaptor:i386 libgdk-pixbuf-xlib-2.0-0:i386 -y
		wget -P ~/install ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/AdbeRdr9.5.5-1_i386linux_enu.deb
		sudo dpkg -i ~/install/AdbeRdr9.5.5-1_i386linux_enu.deb
		sudo rm -r ~/install/AdbeRdr9.5.5-1_i386linux_enu.deb
	fi
}

#VLC
_soft_vlc() {
	if grep -q '"name":"VLC"' ~/install/orderdata; then
		sudo DEBIAN_FRONTEND=nointeractive apt install vlc -y
	fi
}

