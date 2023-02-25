#!/bin/bash

###### Script Install Docker and Docker-Compose (Debian/Debian-based) ######
# Projet Github by MikaPST
# https://github.com/MikaPST/script-docker-dockercompose

git clone https://github.com/MikaPST/script-docker-dockercompose.git \
&& cd script-docker-dockercompose/ \
&& sudo chmod +x start.sh \
&& sudo ./start.sh \
&& cd .. \
&& sudo rm -rf script-docker-dockercompose
