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
echo "These are the credentials specified by Puget Systems during OS installation."
echo.
echo "username: user"
echo "password: Password1"
echo.
echo.
echo "It's highly recommended that you update the password upon receiving the system."
echo 'To do so, open a terminal and type "sudo passwd user" then enter "Password1" as the password.'
echo "Now enter your new password and you're done."