TYPE=($1:-vps) # personal/vps

OLD_USER="$USER"

# Install packages

sudo apt update -y
sudo apt install ca-certificates curl gnupg nala -y # Docker & Nala

# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
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
    pnpm
)

VPS_PACKAGES=(
    caddy
)

sudo nala install ${PACKAGES[@]}

# Setup