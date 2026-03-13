" Templates engine
let g:tmpl_search_paths = ['~/.vim/templates']
let g:tmpl_author_name = $GIT_USER_NAME
let g:tmpl_author_email = $GIT_USER_EMAIL

" FZF
noremap <Leader>t  :FZF<CR>
let g:fzf_layout = { 'down': '40%' }

" Ale
let g:ale_virtualtext_cursor = v:false
let g:ale_hover_cursor = v:false
let g:ale_linters = {
			\   'c': ['clangd'],
			\   'python': ['mypy', 'pylint', 'ruff', 'pylsp'],
			\   'perl': ['perl'],
			\ }

" Fugitive
nmap <leader>gg :Git grep -q <C-R>=expand("<cword>")<CR><CR>

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
	if winwidth(a:winnr) > 45
		let l:s .= ' %{&ft}[%{&fenc!=#""?&fenc:&enc}][%{&ff}] %l/%L %c%V %P '
	else
		let l:s .= ' %l %c'
	endif

	return l:s
endfunction

function! g:CrystallineTablineFn()
	return crystalline#DefaultTabline()
endfunction

let g:crystalline_theme = 'custom'

" LiteCorrect
" also set spell and dictionary completion to text types
augroup litecorrect
	autocmd!
	function TextStuff()
		packadd litecorrect
		call litecorrect#init()
		setlocal spell
		setlocal complete+=k
		setlocal thesaurus=~/.vim/thesaurus/english.txt
	endfunction
	autocmd FileType markdown,mkd,rst,tex,plaintex,text,gitcommit,gitsendemail call TextStuff()
augroup END

" Cscope (that could be a plugin itself..)
if has("cscope")
	" use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
	set cscopetag
	set cscopetagorder=1
	" add all to the quickfix list
	set cscopequickfix=s-,c-,d-,i-,t-,e-,a- "g- don't put it or it will break tags

	nmap <leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>ft :cs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>fe :cs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>ff :cs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap <leader>fi :cs find i <C-R>=expand("<cfile>")<CR><CR>
	nmap <leader>fa :cs find a <C-R>=expand("<cword>")<CR><CR>

	nmap <leader>vs :vert scs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>vg :vert scs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>vc :vert scs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>vd :vert scs find d <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>vt :vert scs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>ve :vert scs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <leader>vf :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap <leader>vi :vert scs find i <C-R>=expand("<cfile>")<CR><CR>
	nmap <leader>va :vert scs find a <C-R>=expand("<cword>")<CR><CR>
endif

" GutenTags
let g:gutentags_generate_on_new = 0
let g:gutentags_generate_on_missing = 1
let g:gutentags_cscope_build_inverted_index = 1
let g:gutentags_modules = ["ctags", "cscope"]

" index from kernel
augroup cdevel
	autocmd!
	function CDevel()
		setlocal spell
		setlocal colorcolumn=81,101
		"set formatprg=clang-format " odd for comments?!
		highlight ColorColumn ctermbg=None ctermfg=DarkRed
	endfunction
	autocmd FileType c,cpp call CDevel()
augroup END

" vimtex and SVED
let g:vimtex_include_search_enabled = 0 "remove this to for gf and ctrl_P
nmap <leader>lv :call SVED_Sync()<CR>

" diffchar
"let g:DiffUnit="Char"

" LSP
packadd lsp
call LspOptionsSet(#{
			\      aleSupport: v:true, ignoreMissingServer: v:true,
			\      autoComplete: v:false, showSignature: v:false,
			\      autoPopulateDiags: v:true, showDiagOnStatusLine: v:true
			\    })
call LspAddServer([#{
			\    filetype: ['c', 'cpp'],
			\    path: '/usr/bin/clangd',
			\    args: ['--background-index']
			\  }, #{
			\    filetype: ['sh', 'bash'],
			\    path: '/usr/bin/bash-language-server',
			\    args: ['start']
			\  }, #{
			\    filetype: ['python'],
			\    path: '/usr/bin/pylsp',
			\  }, #{
			\    name: 'Vim',
			\    filetype: ['vim'],
			\    path: '/usr/local/sbin/vim-language-server',
			\    args: ['--stdio']
			\  }, #{
			\    filetype: ['spec'],
			\    path: '/usr/bin/rpm_lsp_server',
			\    args: ['--stdio']
			\  }])
nnoremap  <leader>lh :LspHover<CR>
nnoremap  <leader>la :LspCodeAction<CR>
nnoremap  <leader>lf :LspFormat<CR>

augroup lspmappings
	autocmd!
	function LspMappings()
		nnoremap <leader>fs :LspSymbolSearch <C-R>=expand("<cword>")<CR><CR>
		nnoremap <leader>fg :LspGotoDefinition<CR>
		nnoremap <leader>fc :LspShowReferences<CR>
		nnoremap <leader>fd :LspOutgoingCalls<CR>
	endfunction
	autocmd FileType sh,bash,python,vim call LspMappings()
augroup END

set completeopt=menu,popup

" Previm
let g:previm_open_cmd = 'xdg-open'
let g:previm_show_header = 0
