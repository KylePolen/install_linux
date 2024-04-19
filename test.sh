#!/bin/bash
scriptname="test.sh"
clear

sudo cp ~/install/assets/puget_icon.png /usr/share/icons
sudo chown user /usr/share/icons/puget_icon.png
gio set -t string ~/Desktop/Puget\ Systems\ Readme.pdf metadata::custom-icon file:///usr/share/icons/puget_icon.png