#!/bin/bash

###### Dockovpn ######
# Projet Github by alekslitvinenk
# https://github.com/dockovpn/dockovpn

#Création du fichier docker-compose.yml
DOCKVOPN_CONFIG=<<EOF 
version: '3'
services:
  dockovpn:
    image: alekslitvinenk/openvpn
    cap_add:
        - NET_ADMIN
    ports:
        - 1194:1194/udp
    environment:
        HOST_ADDR: \${HOST_ADDR}
    volumes:
        - ./openvpn_conf:/doc/Dockovpn
    restart: always
EOF

echo "$DOCKVOPN_CONFIG" > docker-compose.yml

# Exécution de Dockovpn avec Docker-Compose
echo HOST_ADDR=$(curl -s https://api.ipify.org) > .env && \
sudo docker-compose up -d

# Voir les dockers en fonctionnement
sudo docker ps -a

# Temporisation d'initialisation du conteneur docker Dockovpn
echo "Initialisation de Dockovpn, veuillez patienter 10 secondes."
for i in {10..1}; do
    echo "Temps restant: $i secondes..."
    sleep 1
done

# Téléchargement du fichier client.opvn depuis le docker Dockovpn
echo "Téléchargement du fichier client.opvn depuis le docker Dockovpn..."
sudo docker-compose exec -d dockovpn wget -O /doc/Dockovpn/client.ovpn localhost:8080
cd openvpn_conf && ls

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
echo -e "\e[33mLe fichier client.opvn est disponible à l'adresse\e[0m \e[32m${URL}/${FOLDER_CLIENT}/client.zip\e[0m. Veuillez le télécharger.\e[0m"
echo -e "\033[31mAppuyez sur Entrée une fois que vous avez téléchargé le fichier client.zip. Le fichier sera supprimé!\033[0m"

# Attendre que l'utilisateur ait téléchargé le fichier
read

# Désinstaller Apache et supprimer le fichier client.opvn et client.zip
sudo rm client.zip && sudo rm client.ovpn
sudo apt-get remove --purge apache2 -y
sudo rm -f /var/www/

echo -e "\e[32mInstallation terminée, vous pouvez dès à présent utiliser DockOvpn en utilisant le client OpenVPN et la configuration du fichier client.ovpn téléchargé précédemment.\e[0m"
