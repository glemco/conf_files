#! /usr/bin/bash

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
PURPLE="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
BOLD="$(tput bold)"
BLINK="$(tput blink)"
RST="$(tput sgr0)"

FCOL=$BOLD$CYAN

IFS=$'\n'
for line in $(cat files.yaml); do
	IFS=': ' read -r -a arr <<< $line
	file=${arr[0]}
	location=${arr[1]}

	#TODO improve behaviour for those two..
	[ `grep -E "^~" <<< "$location"` ] && location="$HOME""$(tr -d '~' <<< $location)" || SUDO="sudo"
	REC=$([ `grep -E "/$" <<< "$location"` ] && echo "-r" || echo "")

	if $SUDO diff -q $file $location &> /dev/null ; then
		echo "Your $FCOL$file$RST is already up to date!"
		continue
	fi
	echo -n "Do you want to accept the changes to $FCOL$file$RST \
(${GREEN}y$RST/[${RED}n$RST]) or review (${YELLOW}e$RST)? Type (${PURPLE}q$RST) to exit. "
	read answer
	echo $location
	if [ "$answer" == "y" ]; then
		echo "Copying $file to $location and saving a backup in $location.bak"
		if [ -f $location ]; then
			$SUDO cp $REC "$location" "$location".bak
		fi
		$SUDO cp $REC "$file" "$location"
	elif [ "$answer" == "n" ]; then
		echo "Skipping.."
	elif [ "$answer" == "" ]; then
		echo "Selected n. Skipping.."
	elif [ "$answer" == "e" ]; then
		$SUDO vimdiff "$file" "$location"
	elif [ "$answer" == "q" ]; then
		exit
	else
		echo "Choose either y, n or e"
	fi
done
