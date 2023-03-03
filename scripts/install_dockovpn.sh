#!/bin/bash

###### Dockovpn ######
# Projet Github by alekslitvinenk
# https://github.com/dockovpn/dockovpn

# Check for the presence of Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed on this system. Automatic installation via the MikaPST/script-docker-dockercompose Github repo."
    ###### Script Install Docker and Docker-Compose (Debian/Debian-based) ######
    # Projet Github by MikaPST
    # https://github.com/MikaPST/script-docker-dockercompose

    mkdir setup_docker \
    && curl -o setup_docker/start.sh https://raw.githubusercontent.com/MikaPST/script-docker-dockercompose/main/start.sh \
    && chmod +x setup_docker/start.sh \
    && sudo ./setup_docker/start.sh \
    && rm -r setup_docker/
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed on this system. Automatic installation via the MikaPST/script-docker-dockercompose Github repo."
    ###### Script Install Docker and Docker-Compose (Debian/Debian-based) ######
    # Projet Github by MikaPST
    # https://github.com/MikaPST/script-docker-dockercompose

    mkdir setup_docker \
    && curl -o setup_docker/start.sh https://raw.githubusercontent.com/MikaPST/script-docker-dockercompose/main/start.sh \
    && chmod +x setup_docker/start.sh \
    && sudo ./setup_docker/start.sh \
    && rm -r setup_docker/
fi

# Create the docker-compose.yml file in the Dockovpn project's Git folder
HOST_ADDR=$(curl -s https://api.ipify.org)
cat << EOF > docker-compose.yml
version: '3'
services:
  dockovpn:
    image: alekslitvinenk/openvpn
    container_name: dockovpn
    cap_add:
        - NET_ADMIN
    ports:
        - 1194:1194/udp
    environment:
        HOST_ADDR: ${HOST_ADDR}
    volumes:
        - ./openvpn_conf:/doc/Dockovpn
    restart: always
EOF

# Run Dockovpn with Docker-Compose
sudo docker-compose up -d

# View running Docker containers
sudo docker ps -a

# Wait for DockOvpn Docker container initialization
echo "Initializing DockOvpn, please wait for 5 seconds."
for i in {5..1}; do
    echo "Time remaining: $i seconds..."
    sleep 1
done

# Download the client.opvn file from the Dockovpn Docker container
echo "Downloading the client.opvn file from the Dockovpn Docker container..."
sudo docker-compose exec -d dockovpn wget -O /doc/Dockovpn/client.ovpn localhost:8080

# Check that the client.ovpn file was downloaded successfully
if ! find . -name "client.ovpn" -print -quit | grep -q "."; then
    echo -e "\033[31mThe client.ovpn file was not downloaded successfully from the OpenVPN container. Please check Docker logs for more information.\033[0m"
    exit 1
fi

cd "$(dirname "$(find . -name "client.ovpn")")"

# Install Apache and Zip modules
sudo apt-get install apache2 -y
sudo apt-get install zip -y

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

# Uninstall Apache and delete the client.zip and client.ovpn files
sudo rm client.zip
sudo apt-get remove --purge apache2 -y
sudo rm -r /var/www/

echo -e "\e[32mInstallation complete, you can now use DockOvpn by using the OpenVPN client and the configuration from the previously downloaded client.ovpn file.\e[0m"
