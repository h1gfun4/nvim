#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка основных зависимостей
sudo apt install -y curl wget git build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl

# Установка Python 3, pip и полезных утилит
sudo apt install -y python3 python3-pip python3-venv
pip3 install --upgrade pip
pip3 install numpy pandas matplotlib requests flask django black pylint mypy

# Установка Rust и Cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
cargo install exa bat ripgrep fd-find starship

# Установка Go
sudo apt install -y golang
go install github.com/gorilla/mux@latest
go install github.com/gin-gonic/gin@latest

# Установка Node.js (через nvm для последней версии)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
npm install -g typescript yarn create-react-app next nuxt vue-cli eslint prettier

# Установка Docker
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

echo "Установка завершена! Доступны: Python, Rust, Go, Node.js, Docker."