#!/bin/bash
clear

scriptname="clean.sh"

###Kitchen sink approach###
gsettings set org.gnome.desktop.session idle-delay 180
gsettings set org.gnome.desktop.screensaver lock-delay 300
>~/.bash_history
rm ~/.bash_history >/dev/null 2>&1
if [ -f ~/viz.sh ]; then
	rm ~/viz.sh
fi
rm -rf ~/.local/share/Trash/info/* >/dev/null 2>&1
rm -rf ~/.local/share/Trash/files/* >/dev/null 2>&1
rm -rf ~/Downloads/* >/dev/null 2>&1
rm -rf ~/Desktop/* >/dev/null 2>&1
rm ~/Desktop/install >/dev/null 2>&1
sudo chown -R $USER ~/install
rm -rf ~/install >/dev/null 2>&1
sudo rm -rf /var/crash/* >/dev/null 2>&1
rm $0 >/dev/null 2>&1
history -c
history -w
history -cw
>~/.bash_history
rm ~/.bash_history >/dev/null 2>&1
history -cw

###Create password readme on desktop
cp ~/install/assets/Puget_Readme.pdf ~/Desktop/Puget_Readme.pdf