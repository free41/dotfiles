" ============================================================================
" VIM CONFIGURATION
" ============================================================================

" ----------------------------------------------------------------------------
" Plugin Manager (vim-plug)
" ----------------------------------------------------------------------------

" Automatic installation of vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ----------------------------------------------------------------------------
" Plugins
" ----------------------------------------------------------------------------

call plug#begin('~/.vim/plugged')

" Color scheme
Plug 'arcticicestudio/nord-vim'

" Navigation
Plug 'christoomey/vim-tmux-navigator'    " Seamless tmux/vim navigation
Plug 'preservim/tagbar'                  " Tag browser for code navigation
Plug 'preservim/nerdtree'                " File tree explorer

" Code minimap (only if code-minimap binary is installed)
if executable('code-minimap')
  Plug 'wfxr/minimap.vim'
endif

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Editing
Plug 'tpope/vim-commentary'              " Easy commenting with gc
Plug 'tpope/vim-surround'                " Manipulate surrounding quotes/brackets

call plug#end()

" ----------------------------------------------------------------------------
" Color Scheme
" ----------------------------------------------------------------------------

set termguicolors
set background=dark
colorscheme nord

" ----------------------------------------------------------------------------
" General Settings
" ----------------------------------------------------------------------------

" Leader key
let mapleader = " "

" Reduce delay for leader key combinations
set timeoutlen=300

" Line numbers
set number
set relativenumber

" Display
set cursorline                " Highlight current line
set showcmd                   " Show command in bottom bar
set wildmenu                  " Visual autocomplete for command menu
set showmatch                 " Highlight matching brackets
set laststatus=2              " Always show status line

" Search
set incsearch                 " Search as characters are entered
set hlsearch                  " Highlight search matches
set ignorecase                " Case insensitive search
set smartcase                 " Case sensitive when uppercase present

" Indentation
set autoindent                " Auto-indent new lines
set smartindent               " Smart indent
set tabstop=4                 " Number of visual spaces per TAB
set shiftwidth=4              " Number of spaces for auto-indent
set expandtab                 " Tabs are spaces

" Files
set encoding=utf-8            " UTF-8 encoding
set fileencoding=utf-8        " UTF-8 file encoding
set autoread                  " Auto-reload files changed outside vim
set backspace=indent,eol,start " Backspace through everything

" Spell checking
set spelllang=en_us           " Set spell check language
set spellfile=~/.vim/spell/en.utf-8.add " Custom word dictionary

" System clipboard integration
set clipboard=unnamedplus

" Disable backup files
set nobackup
set nowritebackup
set noswapfile

" Enable syntax highlighting
syntax enable
filetype plugin indent on

" ----------------------------------------------------------------------------
" Mouse Support (works in tmux)
" ----------------------------------------------------------------------------

set mouse=a                   " Enable mouse in all modes
if has('mouse_sgr')
    set ttymouse=sgr          " SGR mouse protocol (better tmux support)
else
    set ttymouse=xterm2       " Fallback for older systems
endif

" ----------------------------------------------------------------------------
" Auto-reload Files
" ----------------------------------------------------------------------------

" Automatically reload files changed outside vim
set autoread

" Trigger autoread when changing buffers or gaining focus
autocmd FocusGained,BufEnter * :checktime

" Trigger autoread on cursor hold (after 'updatetime' milliseconds of inactivity)
set updatetime=300
autocmd CursorHold * :checktime

" ----------------------------------------------------------------------------
" Cursor Style
" ----------------------------------------------------------------------------

" Use pipe cursor in insert mode, block in normal mode
let &t_SI = "\e[6 q"  " Insert mode - pipe cursor
let &t_EI = "\e[2 q"  " Normal mode - block cursor
let &t_SR = "\e[4 q"  " Replace mode - underline cursor

" ----------------------------------------------------------------------------
" File Type Specific Settings
" ----------------------------------------------------------------------------

" Markdown - autowrap at 80 characters and enable spell check
autocmd FileType markdown setlocal textwidth=80 formatoptions+=t spell

" Enable spell check for text files, git commits, and documentation
autocmd FileType text,gitcommit,rst setlocal spell

" ----------------------------------------------------------------------------
" Plugin Configuration
" ----------------------------------------------------------------------------

" vim-tmux-navigator: Seamless navigation between vim and tmux
" Uses Ctrl+hjkl to navigate between splits and tmux panes
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :TmuxNavigateRight<cr>

" NERDTree: File tree explorer
nnoremap <leader>n :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.git$', '__pycache__', '\.pyc$', 'node_modules', '\.egg-info$']

" Minimap: Code overview (only if code-minimap binary is installed)
if executable('code-minimap')
  let g:minimap_width = 10
  let g:minimap_auto_start = 1
  let g:minimap_auto_start_win_enter = 1
  let g:minimap_highlight_range = 1
  let g:minimap_highlight_search = 1
  let g:minimap_git_colors = 1
  nnoremap <leader>m :MinimapToggle<CR>

  " Enable mouse scrolling in minimap window
  augroup MinimapMouse
      autocmd!
      autocmd FileType minimap setlocal mouse=a
  augroup END
endif

" Tagbar: Code structure browser
nmap <leader>t :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_sort = 0

" Generate tags automatically using ctags
" Respects .gitignore by using git ls-files
function! GenerateTags()
    " Check if we're in a git repository
    let l:git_root = system('git rev-parse --show-toplevel 2>/dev/null')
    if v:shell_error == 0
        " We're in a git repo - use git ls-files to respect .gitignore
        let l:git_root = substitute(l:git_root, '\n', '', '')
        execute 'silent !cd ' . shellescape(l:git_root) . ' && git ls-files | ctags -L - -f tags 2>/dev/null &'
        echom "Generating tags from git-tracked files..."
    else
        " Not in a git repo - generate tags for all files in current directory
        execute 'silent !ctags -R . 2>/dev/null &'
        echom "Generating tags for current directory..."
    endif
    redraw!
endfunction

" Map to generate tags manually
nnoremap <leader>gt :call GenerateTags()<CR>

" Auto-generate tags on save for certain file types
autocmd BufWritePost *.c,*.cpp,*.h,*.py,*.js,*.ts,*.go,*.rs call GenerateTags()

" FZF: Fuzzy finder
nnoremap <leader>f :Files<CR>
nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>
nnoremap <leader>s :Tags<CR>

" FZF layout and configuration
let g:fzf_layout = { 'down': '40%' }

" Use git ls-files when in a git repo, otherwise fall back to find
let $FZF_DEFAULT_COMMAND = 'git ls-files --cached --others --exclude-standard 2>/dev/null || find . -type f'

" Enhanced Ripgrep command with better defaults
" Search hidden files, follow symlinks, respect .gitignore, smart case
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case --hidden --follow --glob "!.git/*" -- '.shellescape(<q-args>),
  \   1,
  \   fzf#vim#with_preview(),
  \   <bang>0)

" vim-commentary: VSCode-style commenting with Ctrl+/
" Note: In terminal vim, Ctrl+/ sends Ctrl+_
nnoremap <C-_> :Commentary<CR>
vnoremap <C-_> :Commentary<CR>

" ----------------------------------------------------------------------------
" Custom Key Mappings
" ----------------------------------------------------------------------------

" Clear search highlighting with Esc
nnoremap <silent> <Esc> :nohlsearch<CR>

" Buffer navigation
nnoremap <leader>h :bprevious<CR>
nnoremap <leader>l :bnext<CR>

" Better window navigation (in addition to Ctrl+hjkl)
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k

" Quick save
nnoremap <leader>w :w<CR>

" Reload current file
nnoremap <leader>r :edit<CR>

" Window management with Ctrl+w prefix (matching tmux Prefix bindings)
" These mirror the tmux bindings for consistency:
nnoremap <C-w>s :split<CR>                          " Horizontal split (Ctrl+w s)
nnoremap <C-w>v :vsplit<CR>                         " Vertical split (Ctrl+w v)
nnoremap <C-w>q :q<CR>                              " Close window (Ctrl+w q)
nnoremap <C-w>0 :tabfirst<CR>                       " Go to first tab (Ctrl+w 0)
nnoremap <C-w>= <C-w>=                              " Equalize windows (Ctrl+w =)
nnoremap <C-w>_ <C-w>_                              " Maximize height (Ctrl+w _)

" Spell check shortcuts
nnoremap <leader>sp :setlocal spell!<CR>            " Toggle spell check (Space sp)
nnoremap <leader>sn ]s                              " Next spelling error (Space sn)
nnoremap <leader>sb [s                              " Previous spelling error (Space sb)
nnoremap <leader>sa zg                              " Add word to dictionary (Space sa)
nnoremap <leader>s? z=                              " Suggest corrections (Space s?)
