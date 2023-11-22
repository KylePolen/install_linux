#!/bin/bash
scriptname="viz.sh"
clear
sudo apt install git -y && git clone https://github.com/KylePolen/install_linux.git ~/install && cd ~/install && sudo chmod -R +x * && ./imaging.sh