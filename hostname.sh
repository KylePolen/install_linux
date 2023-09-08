#!/bin/bash
scriptname=hostname.sh
clear

serial=$(sudo dmidecode -t 1 | grep -i 'Serial Number: ') && serial=${serial:15} && serial=${serial,,}
sudo hostnamectl set-hostname $serial
sudo sed -i "2s/.*/127.0.0.1	${serial}/" /etc/hosts
