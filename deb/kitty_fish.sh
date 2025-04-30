#!/bin/bash

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Kitty и Fish
sudo apt install -y kitty fish

# Установка Kitty как терминала по умолчанию
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty

# Установка Fish как оболочки по умолчанию для текущего пользователя
chsh -s /usr/bin/fish

# Установка Oh My Fish (опционально, для улучшения Fish)
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

echo "Установка завершена! Терминал заменён на Kitty, оболочка на Fish."