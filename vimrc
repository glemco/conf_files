if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
" Avoid side effects when it was already reset.
if &compatible
  set nocompatible
endif

" When the +eval feature is missing, the set command above will be skipped.
" Use a trick to reset compatible only when the +eval feature is missing.
silent! while 0
  set nocompatible
silent! endwhile

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  set undofile		" keep an undo file (undo changes after closing)
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set wildmenu		" display completion matches in a status line

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Do incremental searching when it's possible to timeout.
if has('reltime')
  set incsearch
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
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
  " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
  autocmd BufNewFile,BufReadPre /media/*,/run/media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
  " start with spec file template
  " 1724126 - do not open new file with .spec suffix with spec file template
  " apparently there are other file types with .spec suffix, so disable the
  " template
  " autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add $PWD/cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  " Revert with ":syntax off".
  syntax on
  "syntax sync minlines=200 "to correct errors

  " I like highlighting strings inside C comments.
  " Revert with ":unlet c_comment_strings".
  let c_comment_strings=1
  " Also switch on highlighting the last used search pattern.
  set hlsearch
endif


" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If set (default), this may break plugins (but it's backward
  " compatible).
  set nolangremap
endif

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
packadd matchit

" All maintenance files together, leave in cwd if the folder is not there
set backupdir=~/.vim/tmp/bak//,.
set undodir=~/.vim/tmp/un//,.
set directory=~/.vim/tmp/swp//,.

" Show hidden characters
set listchars+=tab:..\|,trail:#,extends:>,precedes:<,space:·

" Personal tab indentation
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

" Command completion
set wildmode=longest,full
set wildmenu

" Insert mode completion up to longest common match
"FIXME quite weird, try to find something better
"set completeopt+=longest

" Better vertical split
set splitright
"set splitbelow

" Spell check language
set spelllang=en

" May give some troubles
set nomodeline

" Better consistency for yank
map Y y$

" Keep edited files as hidden buffers (can change without saving)
set hidden

" Smarter diff recognition
if has('nvim-0.3.2') || has("patch-8.1.0360")
  set diffopt=filler,internal,algorithm:histogram,indent-heuristic
endif

" Statusbar also with one window open
set laststatus=2
"set showtabline=2

" Nice automatic folds, leaving the manual ones available
" (somewhat weird sometimes)
"augroup vimrc
"  au BufReadPre * setlocal foldmethod=indent | setlocal foldlevel=99
"  au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
"augroup END

" Highlight trailing spaces
" http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" do it just for C/C++ files?
" 80 characters line
"set colorcolumn=81
"execute "set colorcolumn=" . join(range(81,335), ',')
"highlight ColorColumn ctermbg=Black ctermfg=DarkRed

function! RunCurr()
    if findfile("Makefile") != ""
        make!
    elseif (&filetype == "tex" || &filetype == "plaintex")
        execute("!latexmk *.tex")
    elseif (&filetype == "go")
        execute("!go run " . bufname("%"))
    else
        "perl reads the shebang, no need to execute
        execute("!perl " . bufname("%"))
    endif
endfunction

"ignore files for vimgrep
set wildignore+=cscope.*,tags,*.o,*.ko

" Shortcuts
nnoremap <F9>  :set spell! spell?<CR>
nnoremap <F8>  :set list! list?<CR>
nnoremap <F7>  :copen<CR>
nnoremap <F6>  :set nu! nu?<CR>
"nnoremap <F5>  :syntax sync fromstart<CR>
nnoremap <F5>  :call RunCurr()<CR>
nnoremap <F4>  :noh<CR>
nnoremap <F3>  :Lex<CR>

nnoremap <Leader>]  :call system('ctags -R')<CR>
nnoremap <Leader>[  :call system('cscope -Rbkq')<CR>
vnoremap <Leader>c  "cy :call system('xclip -sel clip', @c)<CR>
nnoremap <Leader>'  :buffers<CR>:buffer<Space>
cabbrev w!! w !sudo tee > /dev/null %

command RestoreSession execute "source Session.vim | silent exec \"!rm -f Session.vim\""

if filereadable('/home/'.$USER.'/.vim/packs.vim')
	source /home/$USER/.vim/packs.vim
endif
