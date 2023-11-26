#!/bin/env bash

TYPE="${1:-vps}" # personal/vps
OLD_USER="$USER"

case "$TYPE" in
    "personal")
        echo "Installing personal packages"
        ;;
    "vps")
        echo "Installing VPS packages"
        ;;
    *)
        echo "Invalid type: $TYPE"
        echo "Valid types: personal, vps"
        exit 1
        ;;
esac

# Install packages

if [[ $EUID -eq 0 ]]; then
   apt install sudo -y
fi

sudo apt update -y
sudo apt install ca-certificates curl gnupg -y # Docker & Nala
echo $TYPE
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
    curl
    wget
    tar
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
    ufw
)
echo 

PERSONAL_PACKAGES=(
    pnpm # https://pnpm.io/installation#on-posix-systems
)

VPS_PACKAGES=(
    caddy
)

case "$TYPE" in
    "personal")
        PACKAGES=(${COMMON_PACKAGES[@]} ${PERSONAL_PACKAGES[@]})
        ;;
    "vps")
        PACKAGES=(${COMMON_PACKAGES[@]} ${VPS_PACKAGES[@]})
        ;;
    *)
        PACKAGES=(${COMMON_PACKAGES[@]})
        ;;
esac

echo "Installing packages: ${PACKAGES[@]}"
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