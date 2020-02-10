syntax enable
set tabstop=2
set softtabstop=2
set expandtab
set number
set showcmd
set cursorline
set wrap

filetype indent on
set wildmenu
set lazyredraw
set showmatch
" highlight matching pairs of brackets, use % to jump between them.
set matchpairs+=<:>
set incsearch
set hlsearch
set ignorecase
nnoremap <leader><space> :nohlsearch<CR>

set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

nnoremap j gj
nnoremap k gk

nnoremap B ^
nnoremap E $
nnoremap $ <nop>
nnoremap ^ <nop>
nnoremap gV `[v`]

map <F6> :NERDTreeToggle<CR>

let mapleader=","
inoremap jk <esc>

" save session
nnoremap <leader>s :mksession<CR>

nnoremap <leader>a :Ag


" Enable backups in tmp dir
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

" nerdtree stuff
let NERDTreeShowHidden=1

if filereadable(expand("~/.vimrc.plug"))
        source ~/.vimrc.plug
endif
