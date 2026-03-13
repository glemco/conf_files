# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

_get_ps1() {
    local red="\[\e[31m\]"
    local green="\[\e[32m\]"
    local yellow="\[\e[33m\]"
    local blue="\[\e[34m\]"
    local purple="\[\e[35m\]"
    local cyan="\[\e[36m\]"
    local bold="\[\e[1m\]"
    local reset="\[\e[0m\]"
    local result=${red}'${?#0}'
    local user="${cyan}${bold}\\u"
    local at="${reset}${blue}@"
    local host="${cyan}${bold}\\h"
    local wdir="${blue}\\W"
    local end="${green}${bold}\\$ ${reset}"
    echo "${cyan}[${user}${at}${host} ${wdir}${reset}${cyan}]${result}${end}"
}

export PS1=$(_get_ps1)
export HISTCONTROL+=":ignoreboth"
export EDITOR="/usr/bin/vim"
export MERGE="vimdiff"
export PYTHONPATH="."

# Source fuzzy find bindings
FZFPATH=/usr/share/fzf/shell/ #fedora
#FZFPATH=/usr/share/fzf/ #arch
#FZFPATH=/usr/share/doc/fzf/examples/ #ubuntu
if [ -f $FZFPATH/key-bindings.bash ] ; then
    . $FZFPATH/key-bindings.bash
fi
if [ -f $FZFPATH/completion.bash ] ; then
    . $FZFPATH/completion.bash
fi
export FZFPATH
#go back to find the root of the project (or home or system root)
_find_root() {
    dir=$PWD
    while ! [ -d $dir/.git -o -d $dir/.svn -o \
        "`realpath -L $dir`" == "$HOME" -o \
        "`realpath -L $dir`" == "/" ]; do
            dir+=/..
    done
    if [ "$PWD" != "$dir" ]; then
        realpath -L $dir --relative-to=$PWD
    else
        : #echo .
    fi
}
export -f _find_root
_fd_find_root() {
    dir=$(_find_root)
    if [ "$dir" != "" ]; then
        printf "%s %s" "--search-path $dir" "--exclude $(realpath --relative-to=$dir .)"
    fi
}
export -f _fd_find_root

export FD_DEFAULT_COMMAND='fd --follow'
if type fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='$FD_DEFAULT_COMMAND --search-path . $(_fd_find_root)'
    #export FZF_DEFAULT_COMMAND='$FD_DEFAULT_COMMAND . $(_find_root) .'
    export FIND_DEFAULT_COMMAND=$FD_DEFAULT_COMMAND
else
    FZF_MAX_DEPTH=6
    export FZF_DEFAULT_COMMAND="command find -L . -depth -mindepth 1 -maxdepth $FZF_MAX_DEPTH \
        \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) \
        -prune \
        -o -type f -print \
        -o -type d -print \
        -o -type l -print 2> /dev/null | cut -b3-"
    export FIND_DEFAULT_COMMAND='find -L'
fi
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
_fzf_compgen_path() {
    $FIND_DEFAULT_COMMAND . "$1"
}
_fzf_compgen_dir() {
    $FIND_DEFAULT_COMMAND --type d . "$1"
}

if type flatpak &> /dev/null; then
	export PATH+=':/var/lib/flatpak/exports/bin/'
fi

export MODULEPATH+=":$HOME/.modulefiles/"
export GIT_USER_NAME="glemco"
export GIT_USER_EMAIL="32201227+glemco@users.noreply.github.com"
