#!/bin/bash

###### Script Install Docker and Docker-Compose (Debian/Debian-based) ######
# Projet Github by MikaPST
# https://github.com/MikaPST/script-docker-dockercompose

mkdir setup_docker \
&& curl -o setup_docker/start.sh https://raw.githubusercontent.com/MikaPST/script-docker-dockercompose/main/start.sh \
&& chmod +x setup_docker/start.sh \
&& sudo ./setup_docker/start.sh \
&& rm -r setup_docker/
