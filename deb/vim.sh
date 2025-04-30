#!/bin/bash

# Проверка на sudo
if [ "$EUID" -ne 0 ]; then
    echo "Запустите скрипт с sudo!"
    exit 1
fi

# Установка Vim 9.0+ (с поддержкой Python3/Lua)
echo "🔹 Установка Vim 9.0 и зависимостей..."
apt update
apt install -y vim-gtk3 python3-pip lua5.4 liblua5.4-dev

# Установка зависимостей для плагинов
echo "🔹 Установка системных зависимостей..."
apt install -y git curl nodejs npm ripgrep silversearcher-ag unzip clang llvm

# Установка Nerd Fonts (FiraCode)
echo "🔹 Установка Nerd Fonts (FiraCode)..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "Fira Code Regular Nerd Font Complete.ttf" \
    https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
fc-cache -fv

# Установка менеджера плагинов (Vim-Plug)
echo "🔹 Установка Vim-Plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Создание конфига Vim (~/.vimrc)
echo "🔹 Настройка ~/.vimrc..."
cat > ~/.vimrc << 'EOF'
" Основные настройки
set nocompatible
filetype plugin indent on
syntax enable
set number
set tabstop=4
set shiftwidth=4
set expandtab
set mouse=a
set termguicolors
set hidden
set nobackup
set nowritebackup
set cmdheight=1
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Цветовая схема (Gruvbox)
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox
set background=dark

" Vim-Plug (менеджер плагинов)
call plug#begin('~/.vim/plugged')

" Файловый менеджер с иконками
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" Автодополнение (LSP через CoC)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Поиск файлов (Telescope-like)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Подсветка синтаксиса (Treesitter)
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Статусная строка с иконками
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'

" Git-интеграция
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Цветовая схема
Plug 'morhetz/gruvbox'

" Отладчик (Vimspector)
Plug 'puremourning/vimspector'

" Дополнительные языки
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' } " Go
Plug 'rust-lang/rust.vim' " Rust
Plug 'pangloss/vim-javascript' " JavaScript
Plug 'leafgarland/typescript-vim' " TypeScript

call plug#end()

" Горячие клавиши
let mapleader = " "

" Файлы и навигация
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fs :w<CR>
nnoremap <leader>qq :q!<CR>

" Git
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gl :Glog<CR>

" LSP (CoC)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>f <Plug>(coc-format)
nnoremap <silent> K :call CocAction('doHover')<CR>

" Форматирование кода
autocmd FileType c,cpp,go,rust nnoremap <leader>f :call CocAction('format')<CR>
autocmd FileType javascript,typescript nnoremap <leader>f :call CocAction('format')<CR>

" Переключение между окнами
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Вставка без копирования
vnoremap <leader>p "_dP

" Настройка CoC.nvim (LSP)
let g:coc_global_extensions = [
  \ 'coc-pyright',
  \ 'coc-clangd',
  \ 'coc-rust-analyzer',
  \ 'coc-tsserver',
  \ 'coc-go',
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-marketplace',
  \ 'coc-snippets',
  \ 'coc-prettier'
  \ ]

inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" Включение подсветки Treesitter
lua << END
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}
END

" Настройка Lightline
set laststatus=2
let g:lightline = {
  \ 'colorscheme': 'gruvbox',
  \ 'component': {
  \   'lineinfo': ' %3l:%-2v',
  \ },
  \ 'component_function': {
  \   'filetype': 'WebDevIconsGetFileTypeSymbol',
  \   'gitbranch': 'FugitiveHead'
  \ },
  \ }

" Настройка Vimspector (отладчик)
let g:vimspector_enable_mappings = 'HUMAN'
nmap <leader>dd :call vimspector#Launch()<CR>
nmap <leader>dx :call vimspector#Reset()<CR>
nmap <leader>dc :call vimspector#Continue()<CR>
nmap <leader>db <Plug>VimspectorToggleBreakpoint
nmap <leader>dt <Plug>VimspectorRunToCursor
EOF

# Установка плагинов
echo "🔹 Установка плагинов Vim..."
vim +PlugInstall +qall

# Установка языковых серверов для CoC
echo "🔹 Установка LSP-серверов..."
npm install -g pyright typescript typescript-language-server vscode-langservers-extracted \
    clangd @volar/vue-language-server bash-language-server

# Установка Go tools
echo "🔹 Установка Go tools..."
export GO111MODULE=on
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest

# Установка Rust tools
echo "🔹 Установка Rust tools..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup component add rust-analyzer

# Настройка Kitty (терминал с поддержкой Nerd Fonts)
echo "🔹 Настройка Kitty..."
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf << 'EOF'
font_family Fira Code Regular Nerd Font Complete
font_size 12
enable_audio_bell no
EOF

# Установка Fish и настройка как оболочки по умолчанию
echo "🔹 Настройка Fish..."
apt install -y fish
chsh -s /usr/bin/fish $USER

# Установка Vimspector (отладчик)
echo "🔹 Настройка Vimspector..."
mkdir -p ~/.vim/pack/vimspector/opt
git clone https://github.com/puremourning/vimspector ~/.vim/pack/vimspector/opt/vimspector
cd ~/.vim/pack/vimspector/opt/vimspector
./install_gadget.py --enable-all

# Готово!
echo "✅ Настройка завершена! Вот основные горячие клавиши:"
echo "  - Файлы: <leader>e (файлы), <leader>ff (поиск), <leader>fb (буферы)"
echo "  - Git: <leader>gs (статус), <leader>gd (дифф), <leader>gb (blame)"
echo "  - LSP: gd (переход к определению), gr (ссылки), <leader>rn (переименовать)"
echo "  - Форматирование: <leader>f"
echo "  - Отладчик: <leader>dd (старт), <leader>db (точка останова)"
echo "  - Переключение окон: Ctrl+h/j/k/l"