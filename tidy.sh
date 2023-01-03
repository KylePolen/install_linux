#!/bin/bash
scriptname="tidy.sh"
clear

#sudo apt install shfmt
clear
read -p "Name a file: " input
shfmt $input > temp.txt
if [ -s temp.txt ]; then
	rm -f $input
	shfmt temp.txt > $input
	rm -f temp.txt
	chmod +x $input
else
	clear
	shfmt $input
	sleep 1000
fi
