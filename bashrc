# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
PURPLE="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 6)\]"
BOLD="\[$(tput bold)\]"
BLINK="\[$(tput blink)\]"
RESET="\[$(tput sgr0)\]"
export PS1="${CYAN}[${CYAN}${BOLD}\u${RESET}${BLUE}@${CYAN}${BOLD}\h ${BLUE}\W${RESET}${CYAN}]${GREEN}${BOLD}\\$ ${RESET}"
export HISTCONTROL+=":ignorespace"
export EDITOR="/usr/bin/vim"
export MERGE="vimdiff"
export PYTHONPATH="."

# Source fuzzy find bindings
if [ -f /usr/share/fzf/shell/key-bindings.bash ] ; then
	. /usr/share/fzf/shell/key-bindings.bash
fi
if [ -f /usr/share/fzf/key-bindings.bash ] ||
	[ -f /usr/share/fzf/completion.bash ] ; then
	. /usr/share/fzf/key-bindings.bash 2> /dev/null | true
	. /usr/share/fzf/completion.bash 2> /dev/null | true
fi #for archlinux (or general, never fail)

#go back to find the root of the project (or home or system root)
_find_root() {
	dir=$PWD
	while ! [ -d $dir/.git -o "`realpath -L $dir`" == "$HOME" -o \
		"`realpath -L $dir`" == "/" ]; do
		dir+=/..
	done
	if [ "$PWD" != "$dir" ]; then
		realpath -L $dir --relative-to=$PWD
	fi
}
export -f _find_root

if type fd &> /dev/null; then
	export FZF_DEFAULT_COMMAND='fd --follow . $(_find_root) .'
	#export FZF_DEFAULT_COMMAND='fd --follow'
else
	FZF_MAX_DEPTH=6
	export FZF_DEFAULT_COMMAND="command find -L . -depth -mindepth 1 -maxdepth $FZF_MAX_DEPTH \
		\\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) \
		-prune \
		-o -type f -print \
		-o -type d -print \
		-o -type l -print 2> /dev/null | cut -b3-"
fi
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
_fzf_compgen_path() {
  $FZF_DEFAULT_COMMAND . "$1"
}
_fzf_compgen_dir() {
  $FZF_DEFAULT_COMMAND --type d . "$1"
}

if type flatpak &> /dev/null; then
	export PATH+=':/var/lib/flatpak/exports/bin/'
fi

export MODULEPATH+=":$HOME/.modulefiles/"
