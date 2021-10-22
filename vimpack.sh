#! /usr/bin/bash

function usage {
	echo "Usage `basename $0` [-o] install|remove|update|list|local-install|load|unload [arguments]"
	exit 1
}

if [ $# -lt 1 ]; then
	usage
fi

PACKDIRSTART="vim/pack/all/start/"
PACKDIROPT="vim/pack/all/opt/"
PACKDIR=$PACKDIRSTART

if [ "$1" == "-o" ]; then
	PACKDIR=$PACKDIROPT
	shift
fi

case "$1" in
	install|in)
		if [ $# -lt 2 ]; then
			echo "Usage $0 $1 url [module-name]"
			exit 2
		fi
		url=$2
		if [ $# -lt 3 ]; then
			module=$(grep -oE '[^/]*$' <<< $url  | sed 's/vim-\|.git$//g')
		else
			module="$3"
		fi
		git submodule add $url ${PACKDIR}"$module"
		vim -c"helptags ALL" -c"q"
		;;
	remove|rm)
		if [ $# -lt 2 ]; then
			echo "Usage $0 $1 module-name"
			exit 2
		fi
		module="$2"
		if [ ! -d ${PACKDIR}$module ]; then
			echo "Module $module doesn't exist in folder"
			exit 3
		fi
		git rm -f ${PACKDIR}"$module"
		rm -rf .git/modules/${PACKDIR}"$module"
		sed -i "\~${PACKDIR}$module~,+1d" .git/config
		vim -c"helptags ALL" -c"q"
		;;
	update)
		if [ $# -ge 2 ]; then
			pack=${PACKDIR}"$2"
		fi
		git submodule update --remote $pack
		vim -c"helptags ALL" -c"q"
		;;
	list|ls)
		ls -1 ${PACKDIR}
		;;
	local-install)
		if [ $# -ge 2 ]; then
			echo "Updating local version of $pack"
			pack=${PACKDIR}"$2"
			rm -r ~/.$pack
			cp -r $pack ~/.$pack
		else
			echo "Updating local version of all packages"
			rm -rv ~/.$PACKDIR*
			cp -rv $PACKDIR* ~/.$PACKDIR
		fi
		;;
	unload)
		if [ $# -lt 2 ]; then
			echo "Usage $0 $1 module-name"
			exit 2
		fi
		module="$2"
		if [ ! -d ${PACKDIRSTART}$module ]; then
			echo "Module $module doesn't exist in autoload folder"
			exit 3
		fi
		git mv ${PACKDIRSTART}"$module" ${PACKDIROPT}"$module"
		;;
	load)
		if [ $# -lt 2 ]; then
			echo "Usage $0 $1 module-name"
			exit 2
		fi
		module="$2"
		if [ ! -d ${PACKDIROPT}$module ]; then
			echo "Module $module doesn't exist in optional folder"
			exit 3
		fi
		git mv ${PACKDIROPT}"$module" ${PACKDIRSTART}"$module"
		;;
	*)
		usage
esac
