" ============================================================================
" VIM CONFIGURATION
" ============================================================================

" ----------------------------------------------------------------------------
" General Settings
" ----------------------------------------------------------------------------

" Leader key
let mapleader = " "

set timeoutlen=300

" Line numbers
set number
set relativenumber

" Display
set cursorline
set showcmd
set wildmenu
set showmatch
set laststatus=2

" Status line
set statusline=
set statusline+=%#DiffAdd#%{(mode()=='n')?'\ \ NORMAL\ ':''}
set statusline+=%#DiffChange#%{(mode()=='i')?'\ \ INSERT\ ':''}
set statusline+=%#DiffDelete#%{(mode()=='r')?'\ \ RPLACE\ ':''}
set statusline+=%#Cursor#%{(mode()=='v')?'\ \ VISUAL\ ':''}
set statusline+=\ %#LineNr#
set statusline+=%#CursorLine#
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ [%{&fileformat}]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\

" Search
set incsearch
set hlsearch
set ignorecase
set smartcase

" Indentation
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

" Files
set encoding=utf-8
set fileencoding=utf-8
set autoread
set backspace=indent,eol,start
set nobackup
set nowritebackup
set noswapfile

" Spell checking
set spelllang=en_us
set spellfile=~/.vim/spell/en.utf-8.add

" Clipboard
set clipboard=unnamedplus

syntax enable
filetype plugin indent on

" ----------------------------------------------------------------------------
" Mouse Support
" ----------------------------------------------------------------------------

set mouse=a
if has('mouse_sgr')
    set ttymouse=sgr
else
    set ttymouse=xterm2
endif

" ----------------------------------------------------------------------------
" Auto-reload Files
" ----------------------------------------------------------------------------

set updatetime=500
autocmd FocusGained,BufEnter,CursorHold * :checktime

" ----------------------------------------------------------------------------
" Cursor Style
" ----------------------------------------------------------------------------

let &t_SI = "\<Esc>[6 q"
let &t_EI = "\<Esc>[2 q"
let &t_SR = "\<Esc>[4 q"

" ----------------------------------------------------------------------------
" File Type Settings
" ----------------------------------------------------------------------------

autocmd FileType markdown setlocal textwidth=80 formatoptions+=t spell
autocmd FileType text,gitcommit,rst,yml,yaml setlocal spell

" ----------------------------------------------------------------------------
" Key Mappings
" ----------------------------------------------------------------------------

" Pane navigation (consistent with tmux Ctrl+hjkl)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Splits
nnoremap <C-w>s :split<CR>
nnoremap <C-w>v :vsplit<CR>
nnoremap <C-w>q :q<CR>
nnoremap <C-w>= <C-w>=
nnoremap <C-w>_ <C-w>_

" Buffer navigation
nnoremap <leader>h :bprevious<CR>
nnoremap <leader>l :bnext<CR>

" Quick save / reload
nnoremap <leader>w :w<CR>
nnoremap <leader>r :edit<CR>

" Clear search highlight
nnoremap <leader><space> :nohlsearch<CR>

" Commenting (manual, no plugin)
nnoremap <C-_> :s/^\(\s*\)/\1" /<CR>:nohlsearch<CR>
vnoremap <C-_> :s/^\(\s*\)/\1" /<CR>:nohlsearch<CR>

" Spell check
nnoremap <leader>sp :setlocal spell!<CR>
nnoremap <leader>sn ]s
nnoremap <leader>sb [s
nnoremap <leader>sa zg
nnoremap <leader>s? z=
