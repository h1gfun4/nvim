#!/usr/bin/env bash
# Скрипт для подготовки оффлайн-окружения DevSecOps/AI/Web на Debian 12
# Требует: sudo, wget, git, pip, npm, docker (опционально)

set -euo pipefail

# --- Настройки ---
OFFLINE_DIR="$HOME/offline_storage"  # Папка для хранения оффлайн-данных
PKG_CACHE_DIR="/var/cache/apt/archives"  # Кеш .deb-пакетов

# Создаем папки
mkdir -p "$OFFLINE_DIR"/{deb_packages,pip_packages,npm_packages,docker_images,ai_models,docs,fonts}

# --- 1. Системные пакеты (APT) ---
echo "🔵 Загрузка системных пакетов..."
sudo apt update

# Список пакетов для DevSecOps/AI/Web
PKGS=(
  # Базовые утилиты
  git curl wget tmux vim neovim fish kitty
  # DevSecOps
  lynis rkhunter chkrootkit nmap wireshark tshark
  # Веб-разработка
  nginx apache2 sqlite3 redis-server
  # Python
  python3 python3-pip python3-venv
  # Node.js
  nodejs npm
  # Docker (если нужно)
  docker.io docker-compose
  # AI/ML
  python3-numpy python3-scipy python3-pandas
)

for pkg in "${PKGS[@]}"; do
  sudo apt-get install --download-only -y "$pkg"
done

# Копируем .deb-файлы в оффлайн-папку
sudo cp -r "$PKG_CACHE_DIR"/*.deb "$OFFLINE_DIR/deb_packages/"

# --- 2. Python (pip) ---
echo "🔵 Загрузка Python-библиотек..."
PY_LIBS=(
  django flask fastapi numpy pandas scikit-learn
  torch torchvision tensorflow onnxruntime
  bandit semgrep safety
)

pip download "${PY_LIBS[@]}" --dest "$OFFLINE_DIR/pip_packages"

# --- 3. Node.js (npm) ---
echo "🔵 Загрузка npm-пакетов..."
NPM_PKGS=(
  express react react-dom typescript eslint prettier
  @vue/cli next
)

for pkg in "${NPM_PKGS[@]}"; do
  npm pack "$pkg" --pack-destination "$OFFLINE_DIR/npm_packages"
done

# --- 4. Docker (если установлен) ---
if command -v docker &>/dev/null; then
  echo "🔵 Загрузка Docker-образов..."
  DOCKER_IMAGES=(
    python:3.9-slim node:16-alpine nginx:alpine
    postgres:13 redis:alpine
  )

  for img in "${DOCKER_IMAGES[@]}"; do
    docker pull "$img"
    docker save -o "$OFFLINE_DIR/docker_images/${img//\//_}.tar" "$img"
  done
fi

# --- 5. AI-модели (Hugging Face) ---
echo "🔵 Загрузка AI-моделей..."
HF_MODELS=(
  distilbert-base-uncased
  google/flan-t5-small
)

for model in "${HF_MODELS[@]}"; do
  git lfs clone --depth 1 "https://huggingface.co/$model" "$OFFLINE_DIR/ai_models/$model"
done

# --- 6. Документация ---
echo "🔵 Загрузка документации..."
# DevDocs (оффлайн-версия)
wget -qO- https://github.com/egoist/devdocs-desktop/releases/latest/download/DevDocs.AppImage \
  > "$OFFLINE_DIR/docs/devdocs.AppImage"
chmod +x "$OFFLINE_DIR/docs/devdocs.AppImage"

# TLDR-страницы
npm install -g tldr
tldr --update
cp -r "$HOME/.tldr" "$OFFLINE_DIR/docs/tldr"

# --- 7. Шрифты для разработки ---
echo "🔵 Загрузка шрифтов..."
FONTS=(
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip"
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip"
)

for font_url in "${FONTS[@]}"; do
  wget -P "$OFFLINE_DIR/fonts" "$font_url"
done

# --- 8. Конфиги для Fish/Vim/Tmux ---
echo "🔵 Копирование конфигов..."
cp -r ~/.config/fish "$OFFLINE_DIR/docs/fish_config"
cp -r ~/.vimrc "$OFFLINE_DIR/docs/vimrc"
cp -r ~/.tmux.conf "$OFFLINE_DIR/docs/tmux.conf"

# --- Готово! ---
echo "✅ Готово! Оффлайн-данные сохранены в: $OFFLINE_DIR"
du -sh "$OFFLINE_DIR"/*