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
	location=$(sed 's~/$~~' <<< $location)

	if $SUDO diff -q $file $location &> /dev/null && [ "$REC" == "" ]; then
		echo "Your $FCOL$file$RST is already up to date!"
		continue
	fi
	if [ -L "$location" ]; then
		echo "Your $FCOL$file$RST is already a symlink, skipping.."
		continue
	fi
	echo -n "Do you want to accept the changes to $FCOL$file$RST \
(${GREEN}y$RST/[${RED}n$RST]), symlink (${BLUE}s${RST}) or review (${YELLOW}e$RST)? \
Type (${PURPLE}q$RST) to exit. "
	read answer
	case "$answer" in
		y)
			echo "Copying $file to $location"
			if [ -f $location ] || [ -d $location ]; then
				echo "Creating a backup in $location.bak"
				$SUDO cp $REC "$location" "$location".bak
			fi
			$SUDO cp $REC "$file" "$location"
			;;
		n)
			echo "Skipping.."
			;;
		"")
			echo "Selected n. Skipping.."
			;;
		e)
			$SUDO vimdiff "$file" "$location"
			;;
		q)
			exit
			;;
		s)
			echo "Linking $file to $location"
			if [ -f $location ] || [ -d $location ]; then
				echo "Creating a backup in $location.bak"
				$SUDO mv "$location" "$location".bak
			fi
			$SUDO ln -sf `realpath "$file"` "$location"
			;;
		*)
			echo "Choose either y, n or e"
	esac
done

git_user_name=$(git config --global user.name | tr -d '\n')
git_user_email=$(git config --global user.email | tr -d '\n')
if [ "$GIT_USER_NAME" != "$git_user_name" -o \
    "$GIT_USER_EMAIL" != "$git_user_email" ]; then
    echo "Updating username and email environment variables from gitconfig"
    sed -i ~/.bashrc -f - << EOF
s/GIT_USER_NAME=.*/GIT_USER_NAME="$git_user_name"/
s/GIT_USER_EMAIL=.*/GIT_USER_EMAIL="$git_user_email"/
EOF
fi
