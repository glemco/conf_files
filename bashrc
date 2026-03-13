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

_set_ps1() {
    local red="\[\e[31m\]"
    local green="\[\e[32m\]"
    local yellow="\[\e[33m\]"
    local blue="\[\e[34m\]"
    local purple="\[\e[35m\]"
    local cyan="\[\e[36m\]"
    local bold="\[\e[1m\]"
    local reset="\[\e[0m\]"
    local result="${red}\${?#0}"

    export PROMPT_COLOR=36
    export PROMPT_DIR_COLOR=34
	local color="\[\e[${PROMPT_COLOR}m\]"
	local dir_color="\[\e[${PROMPT_DIR_COLOR}m\]"
    export PROMPT_START="${color}["
    export PROMPT_USERHOST='\u'"${reset}${dir_color}@${color}${bold}"'\h'
    export PROMPT_END="${color}]${result}${green}${bold}"
    export PROMPT_DIRECTORY="\W"
    export PROMPT_SEPARATOR=" "
}

_set_ps1

export HISTCONTROL+=":ignoreboth"
export EDITOR="/usr/bin/vim"

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
    git rev-parse --show-cdup 2> /dev/null || true
}
export -f _find_root
_fd_find_root() {
    dir=$(_find_root)
    if [ "$dir" != "" ]; then
        printf "%s %s" "--search-path $dir" "--exclude $(realpath --relative-to="$dir" .)"
    fi
}
export -f _fd_find_root

export FD_DEFAULT_COMMAND='fd --follow'
# fd ignores files defined in the gitignore also if added to the tree
# in that case use some more git-aware commands (if we are in a repo)
find_wrapper() {
    if git rev-parse --is-inside-work-tree &> /dev/null ; then
        local root
        root="$(git rev-parse --show-cdup)"
        git ls-files $root ; git ls-files -o --exclude-standard $root
    else
        $FD_DEFAULT_COMMAND "$@"
    fi
}
export -f find_wrapper
if type fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND="find_wrapper \$(_fd_find_root)"
    #export FZF_DEFAULT_COMMAND='$FD_DEFAULT_COMMAND --search-path . $(_fd_find_root)'
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
export FZF_ALT_C_COMMAND="$FIND_DEFAULT_COMMAND --type d ."
_fzf_compgen_path() {
    $FIND_DEFAULT_COMMAND . "$1"
}
_fzf_compgen_dir() {
    $FIND_DEFAULT_COMMAND --type d . "$1"
}

_fzf_complete_git() {
	_fzf_complete --multi --reverse --ansi --no-sort --exact -- "$@" < <(
		if git rev-parse &> /dev/null ; then
			git log --color=always --branches \
				--exclude="*fork/*" --exclude="glemco/*" --remotes \
				--since="1 year" --pretty="%C(yellow)%h %Cgreen[%S]%Creset %s"
		fi
	)
}
_fzf_complete_git_post() {
	awk '{print $1}'
}
[ -n "$BASH" ] && complete -F _fzf_complete_git -o default -o bashdefault git

if type flatpak &> /dev/null; then
	export PATH+=':/var/lib/flatpak/exports/bin/'
fi

export GIT_USER_NAME="glemco"
export GIT_USER_EMAIL="32201227+glemco@users.noreply.github.com"

# configurable environment like API keys, not to commit
# shellcheck disable=SC1090
[ -f ~/.env ] && . ~/.env

if  gpg --export-ssh-key gmonaco &> /dev/null; then
	SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
	GPG_TTY=$(tty)
	export SSH_AUTH_SOCK GPG_TTY
	# agent is started on demand, ping it here
	gpg-connect-agent /bye &> /dev/null
fi
