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

" Completion and LSP
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" ----------------------------------------------------------------------------
" Color Scheme
" ----------------------------------------------------------------------------

" " Enable true color support if available
" " Check for tmux and set appropriate overrides
" if exists('+termguicolors')
"   " Enable true colors in tmux
"   if &term =~# '^screen' || &term =~# '^tmux'
"     let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"     let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
"   endif
"   " Disable termguicolors over SSH to prevent terminal queries
"   if empty($SSH_CONNECTION)
"     set termguicolors
"   endif
" endif

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
let &t_SI = "\<Esc>[6 q"  " Insert mode - pipe cursor
let &t_EI = "\<Esc>[2 q"  " Normal mode - block cursor
let &t_SR = "\<Esc>[4 q"  " Replace mode - underline cursor

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

" coc.nvim: Completion and LSP
" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Apply AutoFix to problem on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects (requires textDocument.documentSymbol support)
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:OR` command for organize imports
command! -nargs=0 OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')

" ----------------------------------------------------------------------------
" Custom Key Mappings
" ----------------------------------------------------------------------------

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
