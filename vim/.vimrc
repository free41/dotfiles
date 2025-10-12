" Vim-Plug automatic installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.vim/plugged')

" Everforest colorscheme
Plug 'sainnhe/everforest'

call plug#end()

" Colorscheme settings
set termguicolors
set background=dark
let g:everforest_background = 'medium'
let g:everforest_better_performance = 1
colorscheme everforest

" Basic settings
set number                  " Show line numbers
set relativenumber          " Show relative line numbers
set cursorline              " Highlight current line
set showcmd                 " Show command in bottom bar
set wildmenu                " Visual autocomplete for command menu
set showmatch               " Highlight matching brackets
set incsearch               " Search as characters are entered
set hlsearch                " Highlight search matches
set ignorecase              " Case insensitive search
set smartcase               " Case sensitive when uppercase present
set autoindent              " Auto-indent new lines
set smartindent             " Smart indent
set tabstop=4               " Number of visual spaces per TAB
set shiftwidth=4            " Number of spaces for auto-indent
set expandtab               " Tabs are spaces
set encoding=utf-8          " UTF-8 encoding
set fileencoding=utf-8      " UTF-8 file encoding
set backspace=indent,eol,start  " Backspace through everything
set clipboard=unnamedplus   " Use system clipboard

" Disable backup files
set nobackup
set nowritebackup
set noswapfile

" Enable syntax highlighting
syntax enable
filetype plugin indent on

" Markdown settings - autowrap at 80 characters
autocmd FileType markdown setlocal textwidth=80 formatoptions+=t
