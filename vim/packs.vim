" Templates engine
let g:tmpl_search_paths = ['~/.vim/templates']
let g:tmpl_author_name = system("git config user.name | tr -d '\n'")
let g:tmpl_author_email = system("git config user.email | tr -d '\n'")

" FZF
noremap <Leader>t  :FZF<CR>
let g:fzf_layout = { 'down': '40%' }

" Ale
let g:ale_c_parse_makefile = 1

" Crystalline
function! StatusLine(current, width)
  let l:s = ''

  if a:current
    let l:s .= crystalline#mode() . crystalline#right_mode_sep('')
  else
    let l:s .= '%#CrystallineInactive#'
  endif
  let l:s .= ' %f%h%w%m%r '
  if a:current
    let l:s .= crystalline#right_sep('', 'Fill') " . ' %{fugitive#head()}'
  endif

  let l:s .= '%='
  if a:current
    let l:s .= crystalline#left_sep('', 'Fill') . ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
    let l:s .= crystalline#left_mode_sep('')
  endif
  if a:width > 80
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

let g:crystalline_statusline_fn = 'StatusLine'
let g:crystalline_tabline_fn = 'TabLine'
let g:crystalline_theme = 'default'
