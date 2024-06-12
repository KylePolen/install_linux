#!/bin/bash
scriptname="format.sh"
clear
	
sudo echo "label: gpt" | sudo sfdisk --force /dev/sda
sudo echo ';' | sudo sfdisk --force /dev/sda
echo "y" | sudo mkfs -t ext4 /dev/sda1
uuid="$(sudo blkid -s UUID -o value /dev/sda1)"
echo "UUID=$uuid /raid ext4 defaults 0 0" | sudo tee -a /etc/fstab
