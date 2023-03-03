<p align=center>
<img src="https://github.com/MikaPST/script-dockovpn/blob/main/logo-script-dockovpn.png?raw=true" height="250">
</p><br>

[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-orange.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

# 📜 OpenVPN VPN Server Deployment Script With Docker
This is a bash script for the **[Dockovpn](https://github.com/dockovpn/dockovpn)** project on Github created by **[alekslitvinenk](https://github.com/alekslitvinenk)**.

The installation is done with the help of the **[Script Install Docker and Docker-Compose (Debian/Debian-based)](https://github.com/MikaPST/script-docker-dockercompose)** project on Github created by **[MikaPST](https://github.com/MikaPST)**.

## ℹ️ Prerequisites:
> **1.** *Any hardware or vps/vds server running Linux. You should have administrative rights on this machine.*

> **2.** *This script requires sudo privileges to run.*

> **3.** *The machine must have internet access.*

# 🔎 Detailed Description of the Script
This shell script allows deploying an OpenVPN server using Docker. It performs the following steps:

* Checks if Docker and Docker Compose are installed. If not, the script automatically installs them via the github repo [MikaPST/script-docker-dockercompose](https://github.com/MikaPST/script-docker-dockercompose).
* Creates the docker-compose.yml file in the Script Dockovpn git project folder.
* Executes Dockovpn with Docker-Compose.
* Waits for 5 seconds for the initialization of the Docker container Dockovpn.
* Downloads the client.ovpn file from the Dockovpn Docker container.
* Verifies that the client.ovpn file has been downloaded correctly.
* Installs Apache and Zip modules.
* Compresses the client.ovpn file and copies it to a randomly named folder in the html directory for downloading.
* Informs the user that the file is available at the URL.
* Waits for the user to download the file.
* Removes the client.ovpn and client.zip files and uninstalls Apache.

Once the script has been executed, the user can use DockOvpn using the OpenVPN client and the configuration of the previously downloaded client.ovpn file.

## ⚠️ Note

The client.opvn file can be used with the OpenVPN client to connect to Dockovpn.

# 📦 Command Lines

## 🔐 Installation of DockOvpn with Docker

Complete installation of the [DockOvpn Project](https://github.com/dockovpn/dockovpn) with Docker and Docker-Compose dependencies.

```bash
curl -o install_dockovpn.sh https://raw.githubusercontent.com/MikaPST/script-dockovpn/main/scripts/install_dockovpn.sh \
&& chmod +x install_dockovpn.sh \
&& ./install_dockovpn.sh
```

## 🐳 Installation of Docker and Docker-Compose Only

Installation of docker and docker-compose in their latest versions.

```bash
mkdir setup_docker \
&& curl -o setup_docker/start.sh https://raw.githubusercontent.com/MikaPST/script-docker-dockercompose/main/start.sh \
&& chmod +x setup_docker/start.sh \
&& sudo ./setup_docker/start.sh \
&& rm -r setup_docker/
```

## 🔄 Regenerate client.opvn File

If for some reason you have to retrieve the client.opvn file again you can run this command.

```bash
cd "$(dirname "$(find ~/ -name "regenerate_client.sh")")" \
&& sudo chmod +x regenerate_client.sh \
&& sudo ./regenerate_client.sh
```
