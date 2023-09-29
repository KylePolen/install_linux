#!/bin/bash
clear
cd /home/$USER/install/assets/ai/TGI-bench
./RUN-ME-4x6000Ada 30
clear
sudo mkdir -p /mnt/ntserver
sudo mount -t cifs //172.17.0.10/scratch/AI -o username=user,password=ilikecoke /mnt/ntserver
until [ -f /home/$USER/install/assets/ai/TGI-bench/summary.out ]
do
	sleep 5
done
sudo cp -f /home/$USER/install/assets/ai/TGI-bench/summary.out /mnt/ntserver/$(hostname).txt
sudo umount /mnt/ntserver
sudo rm -R /mnt/ntserver