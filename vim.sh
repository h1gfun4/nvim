#!/bin/bash

# Проверка, что не запущен из-под root
if [ "$(id -u)" -eq 0 ]; then
  echo "ОШИБКА: Скрипт не должен запускаться через sudo!" >&2
  exit 1
fi

# Цвета для логов
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}=== Установка Vim IDE ===${NC}"

# 1. Установка всех зависимостей
echo -e "${YELLOW}Устанавливаем пакеты...${NC}"
sudo apt update && sudo apt install -y \
  vim-gtk3 git curl nodejs npm ripgrep \
  silversearcher-ag fzf universal-ctags \
  python3-pip

# 2. Настройка npm без sudo
echo -e "${YELLOW}Настраиваем npm...${NC}"
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 3. Создаем .vimrc с полной конфигурацией
echo -e "${YELLOW}Создаем конфиг...${NC}"
cat > ~/.vimrc << 'EOF'
set nocompatible
filetype plugin indent on
syntax enable
set number
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab

" Vim-Plug
call plug#begin('~/.vim/plugged')

" Основные плагины
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'voldikss/vim-floaterm' " Терминал
Plug 'majutsushi/tagbar'    " Панель тегов
Plug 'christoomey/vim-tmux-navigator' " Плавные переходы

call plug#end()

" === Горячие клавиши ===
let mapleader = " "

" Основные команды
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>ff :FZF<CR>
nnoremap <leader>t :TagbarToggle<CR>
nnoremap <leader>fs :w<CR>
nnoremap <leader>qq :q!<CR>

" Управление терминалом
nnoremap <leader>` :FloatermToggle<CR>
tnoremap <leader>` <C-\><C-n>:FloatermToggle<CR>

" Переходы между окнами (как в Tmux)
nnoremap <silent> <C-h> :TmuxNavigateLeft<CR>
nnoremap <silent> <C-j> :TmuxNavigateDown<CR>
nnoremap <silent> <C-k> :TmuxNavigateUp<CR>
nnoremap <silent> <C-l> :TmuxNavigateRight<CR>

" Настройки FZF
let g:fzf_layout = { 'down': '40%' }
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'

" Настройки Floaterm
let g:floaterm_keymap_toggle = '<leader>`'
let g:floaterm_autoclose = 2
let g:floaterm_wintype = 'split'
let g:floaterm_position = 'bottom'

" Настройки Tagbar
let g:tagbar_width = 30
let g:tagbar_show_linenumbers = 2

" Настройки Coc
let g:coc_global_extensions = [
  \ 'coc-pyright',
  \ 'coc-clangd',
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-rust-analyzer'
  \ ]
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
EOF

# 4. Установка Vim-Plug
echo -e "${YELLOW}Устанавливаем Vim-Plug...${NC}"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 5. Установка плагинов
echo -e "${YELLOW}Устанавливаем плагины...${NC}"
vim +PlugInstall +qall

# 6. Установка LSP серверов
echo -e "${YELLOW}Устанавливаем языковые серверы...${NC}"
~/.npm-global/bin/npm install -g \
  pyright typescript typescript-language-server \
  vscode-langservers-extracted

# 7. Установка ctags для Tagbar
echo -e "${YELLOW}Устанавливаем ctags...${NC}"
sudo apt install -y universal-ctags

echo -e "${GREEN}=== Установка завершена! ===${NC}"
echo -e "${YELLOW}Основные горячие клавиши:${NC}"
echo -e "- ${YELLOW}<Пробел>e${NC} - файловый менеджер"
echo -e "- ${YELLOW}<Пробел>ff${NC} - поиск файлов"
echo -e "- ${YELLOW}<Пробел>t${NC} - панель тегов (TagBar)"
echo -e "- ${YELLOW}<Пробел>\`${NC} - переключить терминал"
echo -e "- ${YELLOW}Ctrl+h/j/k/l${NC} - переходы между окнами"
echo -e "- ${YELLOW}gd${NC} - переход к определению"