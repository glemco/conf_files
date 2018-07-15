# .bashrc

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
BEER='\[$(echo -e "$(tput sgr0)$(tput setaf 3)\xf0\x9f\x8d\xba$(tput sgr0)")\]'
WINE='\[$(echo -e "$(tput sgr0)$(tput setaf 5)\xf0\x9f\x8d\xb7$(tput sgr0)")\]'
#PS1="\$([ \$? != 0 ] && echo -e '${BOLD}${RED}:(\n\n${RESET}')"
export PS1="${CYAN}[${CYAN}${BOLD}\u${RESET}${BLUE}@${CYAN}${BOLD}\h ${BLUE}\W${RESET}${CYAN}]${GREEN}${BOLD}\\$ ${RESET}"
export EDITOR="/usr/bin/vim"
export MERGE="vimdiff"

#xhost +local: &> /dev/null
