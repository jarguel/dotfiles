" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible


"NeoBundle Scripts-----------------------------
if has('vim_starting')
  set nocompatible               " Be iMproved

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
NeoBundle  'scrooloose/nerdtree.git'
NeoBundle  'altercation/vim-colors-solarized.git'
NeoBundle  'vim-scripts/taglist.vim'
NeoBundle  'vim-scripts/LargeFile.git'
NeoBundle  'vim-scripts/matchit.zip.git'
NeoBundle  'vim-scripts/snipMate.git'
NeoBundle  'kien/ctrlp.vim'
NeoBundle  'Kocha/vim-systemc'
NeoBundle  'sudar/vim-arduino-syntax'
NeoBundle  'Shougo/unite.vim'
NeoBundle  'mattn/webapi-vim'
NeoBundle  'tyru/open-browser.vim'
NeoBundle  'basyura/unite-yarm'
NeoBundle  'timcharper/textile.vim'

"NeoBundle 'Shougo/neosnippet.vim'
"NeoBundle 'Shougo/neosnippet-snippets'
"NeoBundle 'tpope/vim-fugitive'
"NeoBundle 'flazz/vim-colorschemes'

" You can specify revision/branch/tag.
"NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------


" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup		  " do not keep a backup file, use versions instead
set history=50		" keep 50 lines of command line history
set ruler		      " show the cursor position all the time
set showcmd		    " display incomplete commands
set incsearch		  " do incremental searching
set nu			      " turn on line numbering
set nowrap		    " no wrap long line
set expandtab		  " automatically replace new tabs with spaces

set tabstop=2
set shiftwidth=2

" Don't use Ex mode, use Q for formatting
map Q gq

"------------------------------------------------
" Mapping
"------------------------------------------------
map <F2> [i
map <F3> <c-]>
map <F4> <c-t>
map <F5> @t
map <F6> :%s/\s\+$//<CR>
map <F7> <Esc>:call clearmatches()<Return>
map <F8> <Esc>:'<,'>!format_module<Return>
map <F9>  [c
map <F10> ]c

"Move between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"Resize spluts
nmap <C-Left>   5<C-W>>
nmap <C-Right>  5<C-W><
nmap <C-Up>     5<C-W>-
nmap <C-Down>   5<C-W>+

"Split side
set splitright

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else
  set autoindent		" always set autoindenting on
endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	 	\ | wincmd p | diffthis


" vim-colors-solarized
set t_Co=256
syntax enable
set background=dark
"let g:solarized_termcolors=256
"let g:solarized_degrade=1
colorscheme solarized
call togglebg#map("<F12>")  " toogle background for solarized


" Apply syntax scheme on custom extension
au BufNewFile,BufRead *.vi  set filetype=verilog
au BufNewFile,BufRead *.dve set filetype=verilog
au BufNewFile,BufRead *.sv  set filetype=verilog
au BufNewFile,BufRead *.hs  set filetype=asm
au BufNewFile,BufRead *.scm set filetype=scheme
au BufRead,BufNewFile *.pde set filetype=arduino
au BufRead,BufNewFile *.ino set filetype=arduino

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use

set wildmode=longest,list,full

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" Remove GUI toolbar
"set guioptions-=m  "remove menu bar
"set guioptions-=T  "remove toolbar
set guioptions+=LlRrb
set guioptions-=LlRrb


" Additionnal hightlight
highlight CodingStyleError ctermbg=lightred guibg=lightred
"au WinEnter,BufWinEnter,BufRead,BufEnter * let w:m1 = matchadd('CodingStyleError', '\%81v.\+', -1) " Virtual column 81 and more
"au WinEnter,BufWinEnter,BufRead,BufEnter * match CodingStyleError /\%81v.\+/

" Trailing whitespaces
au WinEnter,BufWinEnter,BufRead,BufEnter * 2match CodingStyleError /\s\+$/
au InsertEnter * 2match CodingStyleError /\s\+\%#\@<!$/
au InsertLeave * 2match CodingStyleError /\s\+$/

" It seems that vim does not handle sucessive calls of the match command
" gracefully. Since BufWinEnter commands are executed every time a buffer is
" displayed (i.e., switching to another file), the match command is executed
" many times during a vim session. This seems to lead to a memory leak which
" slowly impacts performance (for example scrolling and writing become
" unbearable slow). Include the following line to fix the issue:
autocmd BufWinLeave * call clearmatches()

" taglists
let Tlist_Use_Right_Window = 1

" textile
let g:TextileOS="Linux"
let g:TextileBrowser="/usr/bin/google-chrome"

