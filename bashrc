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

alias xopen=xdg-open

#xhost +local: &> /dev/null
export PATH+=':/opt/Xilinx/Vivado/2020.1/bin'
alias vivado='vivado -mode tcl'
