#!/bin/bash
scriptname="viz.sh"
clear

echo "Resetting machine ID and acquiring unique IP"
#sudo rm /etc/machine-id
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo netplan generate
sudo netplan apply

until ping -c1 www.google.com >/dev/null 2>&1; do :; done

sudo apt install git -y && git clone https://github.com/KylePolen/install_linux.git ~/install && cd ~/install && sudo chmod -R +x * && ./imaging.sh