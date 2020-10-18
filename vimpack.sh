#! /usr/bin/sh

function usage {
	echo "Usage `basename $0` [-o] install|remove|update|list|local-install [arguments]"
	exit 1
}

if [ $# -lt 1 ]; then
	usage
fi

PACKDIR="vim/pack/all/start/"

if [ "$1" == "-o" ]; then
	PACKDIR="vim/pack/all/opt/"
	shift
fi

case "$1" in
	install)
		if [ $# -lt 2 ]; then
			echo "Usage $0 $1 url [module-name]"
			exit 2
		fi
		url=$2
		if [ $# -lt 3 ]; then
			module=$(grep -oE '[^/]*$' <<< $url)
		else
			module="$3"
		fi
		git submodule add $url ${PACKDIR}"$module"
		;;
	remove)
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
		;;
	update)
		if [ $# -ge 2 ]; then
			pack=${PACKDIR}"$2"
		fi
		git submodule update --remote $pack
		;;
	list)
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
	*)
		usage
esac
