#!/bin/bash

###### Dockovpn ######
# Projet Github by alekslitvinenk
# https://github.com/dockovpn/dockovpn

# Vérification de la présence de Docker et de Docker Compose
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé sur ce système. Installation automatique via le repo github MikaPST/script-docker-dockercompose."
    sudo chmod +x install_docker_dockercompose.sh && \
    sudo ./install_docker_dockercompose.sh
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose n'est pas installé sur ce système. Installation automatique via le repo github MikaPST/script-docker-dockercompose."
    sudo chmod +x install_docker_dockercompose.sh && \
    sudo ./install_docker_dockercompose.sh
fi

#Création du fichier docker-compose.yml dans le dossier git projet Script Dockovpn
HOST_ADDR=$(curl -s https://api.ipify.org)
cat << EOF > ~/docker-compose.yml
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
        - ~/openvpn_conf:/doc/Dockovpn
    restart: always
EOF
cd ~/

# Exécution de Dockovpn avec Docker-Compose
sudo docker-compose up -d

# Voir les dockers en fonctionnement
sudo docker ps -a

# Temporisation d'initialisation du conteneur docker Dockovpn
echo "Initialisation de DockOvpn, veuillez patienter 10 secondes."
for i in {10..1}; do
    echo "Temps restant: $i secondes..."
    sleep 1
done

# Téléchargement du fichier client.opvn depuis le docker Dockovpn
echo "Téléchargement du fichier client.opvn depuis le docker Dockovpn..."
echo HOST_ADDR=$(curl -s https://api.ipify.org) > .env && \
sudo docker-compose exec -d dockovpn wget -O /doc/Dockovpn/client.ovpn localhost:8080

# Vérification que le fichier client.ovpn a été correctement téléchargé
if [ ! -f "~/openvpn_conf/client.ovpn" ]; then
    echo "Le fichier client.ovpn n'a pas été téléchargé avec succès depuis le conteneur OpenVPN. Veuillez vérifier les logs Docker pour plus d'informations."
    exit 1
fi
cd ~/openvpn_conf/

# Installation des modules Apache et Zip
sudo apt-get install apache2 -y
sudo apt-get install zip -y

# Compression du fichier client.opvn et copie dans un dossier au nom aléatoir vers le dossier html pour téléchargement
FOLDER_CLIENT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
sudo mkdir /var/www/html/$FOLDER_CLIENT/
sudo zip client.zip client.ovpn && sudo cp client.zip /var/www/html/$FOLDER_CLIENT/

# Informe l'utilisateur que le fichier est disponible à l'adresse URL
IP=$(curl -s https://api.ipify.org)
URL="http://${IP}"
echo -e "\e[33mLe fichier client.opvn est disponible à l'adresse\e[0m \e[32m${URL}/${FOLDER_CLIENT}/client.zip\e[0m\e[33m. Veuillez le télécharger.\e[0m"
echo -e "\033[31mAppuyez sur Entrée une fois que vous avez téléchargé le fichier client.zip. Le fichier sera supprimé!\033[0m"

# Attendre que l'utilisateur ait téléchargé le fichier
read

# Désinstaller Apache et supprimer le fichier client.opvn et client.zip
sudo rm client.zip && sudo rm client.ovpn
sudo apt-get remove --purge apache2 -y
sudo rm -f /var/www/

echo -e "\e[32mInstallation terminée, vous pouvez dès à présent utiliser DockOvpn en utilisant le client OpenVPN et la configuration du fichier client.ovpn téléchargé précédemment.\e[0m"
