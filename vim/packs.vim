" Templates engine
let g:tmpl_search_paths = ['~/.vim/templates']
let g:tmpl_author_name = $GIT_USER_NAME
let g:tmpl_author_email = $GIT_USER_EMAIL

" FZF
noremap <Leader>t  :FZF<CR>
noremap <Leader>g  :GitFiles<CR>
let g:fzf_layout = { 'down': '40%' }

" Ale
let ale_virtualtext_cursor = 'disabled'
let g:ale_c_parse_makefile = 1
let g:ale_linters = {'perl': ['perl']}
let g:ale_c_ccls_init_options = {
\   'cache': {
\       'directory': '/tmp/ccls/cache'
\   }
\ }
"let g:ale_c_ccls_executable = 'ccls -v 2'
let g:ale_c_cc_executable = 'arm-none-eabi-gcc'
let g:ale_c_clangd_options = '--query-driver=/opt/st/gcc-arm-none-eabi-10-2020-q4-major/bin/arm-none-eabi-gcc'
let g:ale_fixers = {
\   'c': [
\       'clang-format',
\   ],
\   'cpp': [
\       'clang-format',
\   ]
\ }


" Crystalline
let g:crystalline_separators = [
      \ { 'ch': '', 'alt_ch': '', 'dir': '>' },
      \ { 'ch': '', 'alt_ch': '', 'dir': '<' },
      \ ]

function! CrystallineStatuslineFn(winnr)
    let l:s = ''

    if a:winnr == winnr()
        let l:s .= crystalline#ModeSection(0, 'A', 'B')
    else
        let l:s .= crystalline#HiItem('InactiveFill')
    endif
    " TODO dynamic based on number of splits?
    let l:s .= ' %.' . winwidth(a:winnr)/2 . 'f%h%w%m%r '
    if a:winnr == winnr()
        let l:s .= crystalline#Sep(0, 'B', 'Fill')
    endif

    let l:s .= '%='
    if a:winnr == winnr()
        let l:s .= crystalline#Sep(1, 'Fill', 'B')
        let l:s .= ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}%{gutentags#statusline(""," ")}'
        let l:s .= crystalline#Sep(1, crystalline#ModeGroup('Fill'), crystalline#ModeGroup('A'))
    endif
    if winwidth(a:winnr) > 60
        let l:s .= ' %{&ft}[%{&fenc!=#""?&fenc:&enc}][%{&ff}] %l/%L %c%V %P '
    else
        let l:s .= ' '
    endif

    return l:s
endfunction

function! TabLine() " acclamation to avoid conflict
	let l:s = '' " complete tabline goes here
	" loop through each tab page
	for t in range(tabpagenr('$'))
		" set highlight
		if t + 1 == tabpagenr()
			let l:s .= crystalline#mode_color()
		elseif (t + tabpagenr()) % 2 == 0 " the closest to the selected are brighter
		"elseif t % 2 == 0 " always the same regardless of selection
			let l:s .= '%#Crystalline#'
		else " change colors to alternate tabs
			let l:s .= '%#CrystallineInactive#'
		endif
		" get buffer names and statuses
		let l:n = ''      "temp string for buffer names while we loop and check buftype
		let l:m = 0       " &modified counter
		let bc = len(tabpagebuflist(t + 1))     "counter to avoid last ' '
		" add a space before the name (could add also a separator here)
		let l:s .= ' '
		" loop through each buffer in a tab
		for b in tabpagebuflist(t + 1)
			" buffer types: quickfix gets a [Q], help gets [H]{base fname}
			" others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
			if getbufvar( b, "&buftype" ) == 'help'
				let l:n .= '[H]' . fnamemodify( bufname(b), ':t:l:s/.txt$//' )
			elseif getbufvar( b, "&buftype" ) == 'quickfix'
				let l:n .= '[Q]'
			else
				let l:n .= pathshorten(bufname(b))
			endif
			" check and ++ tab'l:s &modified count
			if getbufvar( b, "&modified" )
				let l:m += 1
			endif
			" no final ' ' added...formatting looks better done later
			if bc > 1
				let l:n .= ' '
			endif
			let bc -= 1
		endfor
		" add modified label [l:n+] where l:n pages in tab are modified
		if l:m > 0
			let l:s .= '[' . l:m . '+]'
		endif
		" select the highlighting for the buffer names
		" my default highlighting only underlines the active tab
		" buffer names.
		"" if t + 1 == tabpagenr()
		"" 	let l:s .= '%#TabLineSel#'
		"" else
		"" 	let l:s .= '%#TabLine#'
		"" endif
		" add buffer names
		if l:n == ''
			let l:s.= '[New]'
		else
			let l:s .= l:n
		endif
		" switch to no underlining and add final space to buffer list
		let l:s .= ' '
	endfor
	" after the last tab fill with TabLineFill and reset tab page nr
	let l:s .= '%#CrystallineInactive#%T'
	" right-align the label to close the current tab page
	if tabpagenr('$') > 1
		let l:s .= '%=%#CrystallineInactive#%999X'
		let l:s .= crystalline#mode_color()
		let l:s .= 'X'
	endif
	return l:s
endfunction

"TODO port the previous one
function! g:CrystallineTablineFn()
  return crystalline#DefaultTabline()
endfunction

let g:crystalline_theme = 'custom'

" LiteCorrect
" also set spell and dictionary completion to test types
augroup litecorrect
	autocmd!
    function TextStuff()
        packadd litecorrect
        call litecorrect#init()
        setlocal spell
        setlocal complete+=k
        setlocal thesaurus=~/.vim/thesaurus/english.txt
    endfunction
	autocmd FileType markdown,mkd,tex,plaintex,text,gitcommit,gitsendemail call TextStuff()
augroup END

" Cscope (that could be a plugin itself..)
if has("cscope")
    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag
    set cscopetagorder=1
    " add all to the quickfix list
	set cscopequickfix=s-,c-,d-,i-,t-,e-,a- "g- don't put it or it will break tags
    " add any cscope database in current directory
    "if filereadable("cscope.out")
    "    cs add cscope.out "already there?
    "" else add the database pointed to by environment variable
    "elseif $CSCOPE_DB != ""
    "    cs add $CSCOPE_DB
    "endif

    "nnoremap <leader>fa :call CscopeFindInteractive(expand('<cword>'))<CR>
    "nnoremap <leader>l :call QuickFixToggle()<CR>
    " s: Find this C symbol
    nnoremap  <leader>fs :cs find s <C-R>=expand('<cword>')<CR><CR>
    " g: Find this definition
    nnoremap  <leader>fg :cs find g <C-R>=expand('<cword>')<CR><CR>
    " d: Find functions called by this function
    nnoremap  <leader>fd :cs find d <C-R>=expand('<cword>')<CR><CR>
    " c: Find functions calling this function
    nnoremap  <leader>fc :cs find c <C-R>=expand('<cword>')<CR><CR>
    " t: Find this text string
    nnoremap  <leader>ft :cs find t <C-R>=expand('<cword>')<CR><CR>
    " e: Find this egrep pattern
    nnoremap  <leader>fe :cs find e <C-R>=expand('<cword>')<CR><CR>
    " f: Find this file
    "nnoremap  <leader>ff :cs find f <C-R>=expand('<cfile>')<CR><CR>
    nnoremap  <leader>ff :cs find f <C-R>=expand('<cword>')<CR><CR>
    " i: Find files #including this file
    "nnoremap  <leader>fi :cs find i ^<C-R>=expand('<cfile>')<CR>$<CR>
    nnoremap  <leader>fi :cs find i <C-R>=expand('<cword>')<CR><CR>
endif

" GutenTags
let g:gutentags_ctags_extra_args = ["--exclude=devices/wireless_4000/Second_Stage_Bootloader"]
let g:gutentags_cscope_build_inverted_index = 1
let g:gutentags_modules = ["ctags", "gtags_cscope"]

" index from kernel
augroup cdevel
	autocmd!
    function CDevel()
        setlocal nocscopeverbose
        setlocal tags+=/opt/linux/tags
        cs add /opt/linux/cscope.out /opt/linux/
        setlocal cscopeverbose
        setlocal colorcolumn=81
        highlight ColorColumn ctermbg=None ctermfg=DarkRed
    endfunction
	autocmd FileType c,cpp call CDevel()
augroup END

autocmd BufRead,BufNewFile Jenkinsfile set filetype=groovy
" proemion configurator
autocmd BufRead,BufNewFile *.cfg set filetype=xml

" vimtex and SVED
let g:vimtex_include_search_enabled = 0 "remove this to for gf and ctrl_P
nmap <leader>lv :call SVED_Sync()<CR>

" markdown preview
let g:mkdp_preview_options = {
    \ 'disable_filename': 1,
    \ }
let g:mkdp_markdown_css = $HOME.'/.vim/markdown.css'

" diffchar
"let g:DiffUnit="Char"

" Grayout
"let g:grayout_libclang_path = '/usr/lib/llvm-14/lib/'
highlight PreprocessorGrayout cterm=italic ctermfg=DarkGray gui=italic guifg=#6c6c6c
nmap <leader>g :GrayoutUpdate<CR>

" cucumber
let b:cucumber_steps_glob = '.vscode/steps/*.js'
let b:match_all_types = v:true

"let s:cucumber_language_server = '/home/monaco/Desktop/language-server/bin/cucumber-language-server.cjs'
let s:cucumber_language_server = '/home/monaco/.local/bin/cucumber-language-server.cjs'

" YouCompleteMe
"let g:ycm_min_num_of_chars_for_completion = 99
"let g:ycm_auto_trigger = 0
"let g:ycm_language_server =
"            \ [
"            \   {
"            \     'name': 'cucumber',
"            \     'cmdline': [ s:cucumber_language_server, '--stdio' ],
"            \     'filetypes': [ 'cucumber' ]
"            \   }
"            \ ]

" LSP
packadd lsp
" can use this as custom handler
function s:do_nothing(a, b) dict
endfunction
call LspOptionsSet(#{aleSupport: v:true, autoComplete: v:false})
call LspAddServer([#{
            \    name: 'clangd',
            \    filetype: ['c', 'cpp'],
            \    path: '/usr/bin/clangd',
            \    args: ['--background-index', '--query-driver=/opt/st/gcc-arm-none-eabi-10-2020-q4-major/bin/arm-none-eabi-gcc']
            \  }])
call LspAddServer([#{
            \    name: 'cucumber',
            \    filetype: ['cucumber'],
            \    debug: v:true,
            \    path: s:cucumber_language_server,
            \    args: ['--stdio'],
            \    customRequestHandlers: {'workspace/semanticTokens/refresh': function('s:do_nothing') }
            \  }])
call LspAddServer([#{
            \    name: 'Jenkinsfile',
            \    filetype: ['groovy'],
            \    path: '/usr/bin/java',
            \    args: ['-jar', '/home/monaco/.local/share/groovy-language-server-all.jar']
            \  }])
call LspAddServer([#{
            \    name: 'Javascript',
            \    filetype: ['typescript', 'javascript'],
            \    path: '/home/monaco/.local/bin/typescript-language-server',
            \    args: ['--stdio']
            \  }])
call LspAddServer([#{
            \    name: 'Bash',
            \    filetype: ['sh', 'bash'],
            \    path: '/home/monaco/.local/bin/bash-language-server',
            \    args: ['start']
            \  }])
nnoremap  <leader>lh :LspHover<CR>
nnoremap  <leader>la :LspCodeAction<CR>
nnoremap  <leader>ld :LspDocumentSymbol<CR>

au BufNewFile,BufRead,BufEnter packadd lsp

" EditorConfig (bundled)
packadd editorconfig
