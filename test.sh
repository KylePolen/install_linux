#!/bin/bash
scriptname="test.sh"
clear

		echo "Puget Systems Default Credentials" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "Username: user" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "Password: Password1!" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "==================================================" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "By default Puget Systems does not set a root password" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "" | sudo tee -a /home/$USER/Puget\ Systems\ Readme
		echo "To change a password run 'sudo passwd <user>', where <user> is the user in question i.e. 'root', enter the current sudo password and then set the new password" | sudo tee -a /home/$USER/Puget\ Systems\ Readme