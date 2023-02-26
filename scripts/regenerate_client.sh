#!/bin/bash

###### Dockovpn ######
# Projet Github by alekslitvinenk
# https://github.com/dockovpn/dockovpn

# Download the client.opvn file from the Dockovpn Docker container
echo "Downloading the client.opvn file from the Dockovpn Docker container..."
sudo docker-compose exec -d dockovpn wget -O /doc/Dockovpn/client.ovpn localhost:8080

# Check that the client.ovpn file was downloaded successfully
if ! find openvpn_conf/ -name "client.ovpn" -print -quit | grep -q "."; then
    echo -e "\033[31mThe client.ovpn file was not downloaded successfully from the OpenVPN container. Please check Docker logs for more information.\033[0m"
    exit 1
fi

cd openvpn_conf/

# Check if the zip module is correctly installed. If not, install it.
if ! command -v zip &> /dev/null; then
    echo "The zip module is not installed. Loading installation..."
    sudo apt-get install zip -y
    echo "\e[32mZip module successfully installed.\e[0m"
else
    echo "\e[32mThe zip module is already installed.\e[0m"
fi

# Check if the apache module is installed correctly. If not, install it.
if ! command -v apache2 &> /dev/null; then
    echo "Apache web server is not installed. Loading installation..."
    sudo apt-get update -y
    sudo apt-get install apache2 -y
    sudo apache2 reload
    echo "\e[32mApache web server successfully installed.\e[0m"
else
    echo "\e[32mThe Apache web server is already installed.\e[0m"
fi

# Compress the client.opvn file and copy to a randomly named folder for download
FOLDER_CLIENT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
sudo mkdir /var/www/html/$FOLDER_CLIENT/
sudo zip client.zip client.ovpn && sudo cp client.zip /var/www/html/$FOLDER_CLIENT/

# Inform the user that the file is available at the URL
IP=$(curl -s https://api.ipify.org)
URL="http://${IP}"
echo -e "\e[33mThe client.opvn file is available at the address\e[0m \e[32m${URL}/${FOLDER_CLIENT}/client.zip\e[0m\e[33m. Please download it.\e[0m"
echo -e "\033[31mPress Enter once you have downloaded the client.zip file. The file will be deleted!\033[0m"

# Wait for the user to download the file
read

# Uninstall Apache and delete the client.opvn and client.zip files
sudo rm client.zip && sudo rm client.ovpn
sudo apt-get remove --purge apache2 -y
sudo rm -f /var/www/

echo -e "\e[32mInstallation complete, you can now use DockOvpn by using the OpenVPN client and the configuration from the previously downloaded client.ovpn file.\e[0m"
