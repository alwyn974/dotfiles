#!/bin/env bash

TYPE=($1:-vps) # personal/vps

OLD_USER="$USER"

# Install packages

if [[ $EUID -eq 0 ]]; then
   apt install sudo -y
fi

sudo apt update -y
sudo apt install ca-certificates curl gnupg -y # Docker & Nala

# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
if [ "$TYPE" == "vps" ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
else
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y

COMMON_PACKAGES=(
    zsh
    inxi
    neofetch
    bpytop
    nano
    git
    curl
    wget
    tar
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
)

PERSONAL_PACKAGES=(
    pnpm # https://pnpm.io/installation#on-posix-systems
)

VPS_PACKAGES=(
    caddy
)

switch ($TYPE) {
    case "personal":
        PACKAGES=($COMMON_PACKAGES $PERSONAL_PACKAGES)
        break
    case "vps":
        PACKAGES=($COMMON_PACKAGES $VPS_PACKAGES)
        break
    default:
        PACKAGES=($COMMON_PACKAGES)
        break
}

sudo nala install -y ${PACKAGES[@]}

# Setup

# Docker
sudo groupadd docker
sudo usermod -aG docker $OLD_USER
newgrp docker

# Zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
cp .zshrc $HOME/.zshrc
cp .p10k.zsh $HOME/.p10k.zsh
source $HOME/.zshrc