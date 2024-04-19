#!/bin/bash
scriptname="test.sh"
clear

echo "Puget Systems Default Credentials" | tee -a /home/$USER/Puget_Systems_Readme
echo "Username: user" | tee -a /home/$USER/Puget_Systems_Readme
echo "Password: Password1!" | tee -a /home/$USER/Puget_Systems_Readme
echo "" | tee -a /home/$USER/Puget_Systems_Readme
echo "==================================================" | tee -a /home/$USER/Puget_Systems_Readme
echo "" | tee -a /home/$USER/Puget_Systems_Readme
echo "By default Puget Systems does not set a root password. To change a password run 'sudo passwd <user>', where <user> is the user in question i.e. 'root', enter the current password and then set the new password" | tee -a /home/$USER/Puget_Systems_Readme
echo "Example: 'sudo passwd root'" | tee -a /home/$USER/Puget_Systems_Readme