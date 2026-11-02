#!/usr/bin/env bash

install_tools() {
    sudo apt update

    sudo apt install git -y
    sudo apt install gh -y

    sudo apt install snapd -y

    sudo apt install curl -y

    sudo apt install wget -y

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash

    source ~/.bashrc

    nvm install lts

    sudo apt install golang-go gopls delve -y

    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x ./dotnet-install.sh
    ./dotnet-install.sh --channel 10.0
    rm ./dotnet-install.sh

    # sudo apt-get remove docker docker-engine docker.io containerd runc
    sudo apt install -y docker docker-ce docker-ce-cli docker-buildx docker-buildx-plugin docker.io docker-clean docker-compose docker-compose-plugin docker-compose-v2 docker-registry docker-secrets-engine

    sudo snap install postman

    sudo snap install insomnia
    
    sudo snap install dbeaver-ce
    
    sudo snap install --classic code

    sudo snap install antigravity-ide-snap --classic

    sudo snap install chromium
}
