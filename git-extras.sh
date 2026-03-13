#! /usr/bin/bash

######################################################################
# @author      : Gabriele Monaco (gmonaco@redhat.com)
# @file        : git-extras
# @created     : Thursday May 29, 2025 08:29:31 CEST
#
# @description : Extra git commands to be configured as aliases
######################################################################

iterate() {
	# Iterate over all patches since upstream
	local do_git_diff=0

	local filenames=()
	local block_exit=0
	# quit the difftool but continue with next commit
	should_block_exit() {
		if [ "$block_exit" -eq 0 ]; then
			exit 0
		fi
		block_exit=0
	}

trap should_block_exit SIGINT

if [ "$1" == -h ] || [ "$1" == --help ]; then
	cat << EOF
$0 [<upstream>] [<path>...]

Iterate over commits returned by git cherry and
offer the possibility to open a git difftool.
If paths are supplied, just show commits and diffs involving those.
EOF
exit
fi

local last=$#
for i in $(seq $# -1 1); do
	local arg="${!i}"
	if [ -e "$arg" ]; then
		filenames+=("$arg")
		last=$((last-1))
	else
		break
	fi
done
set -- "${@:1:last}"

if [ "$1" == -d ] || [ "$1" == --diff ]; then
	do_git_diff=1
	shift
fi

for commit in $(git cherry "$@" | cut -d" " -f2); do
	if [ -z "$(git show "$commit" -- "${filenames[@]}")" ]; then
		continue
	fi
	echo
	git show -s --format=%B "$commit" | head -n1
	git diff --stat "$commit"~ "$commit" "${filenames[@]}"
	read -r -p "Inspect this commit? [Y/n] " response
	if [ "$response" == n ] || [ "$response" == N ]; then
		continue
	fi
	if [ $do_git_diff -eq 1 ]; then
		git diff "$commit"~ "$commit" "${filenames[@]}"
		continue
	fi
	block_exit=1
	git difftool "$commit"~ "$commit" "${filenames[@]}"
	block_exit=0
done
}

deploy() {
	# Push to the current and staging branches on glemco
	local branch remote
	branch=$(git rev-parse --abbrev-ref HEAD)
	remote=glemco

	# TODO if an argument is passed, use that commit instead of HEAD
	# e.g. to push from a previous commit and not the last
	# that may need refs/heads/staging_ to create the new branch
	# (do not validate the commit hash)

	if ! git remote get-url $remote &> /dev/null ; then
		echo This command is not supported on this repository
		exit 1
	fi
	if [ "$1" != -y ]; then
		read -r -p "Push branch $branch on $remote? [Y/n] " response
		if [ "$response" == n ] || [ "$response" == N ]; then
			exit
		fi
	fi

	git push -f $remote "$branch"
	git push -f $remote "$branch":staging_"$branch"
}

grab_patch() {
	# Fetch and apply the provided patches
	set -e

	if [ $# -lt 1 ]; then
		echo "Usage $0 links"
		exit 1
	fi
	for msg in "$@"; do
		# TODO allow some cherry pick (if not all work)
		# something like if next matches format, use and shift
		b4 am --no-cover -l -s -3 "$msg"
	done
	git am -3 ./*.mbx
	rm -f ./*.mbx
}

prepare_pr() {
	# Prepare a pull request on the current branch
	local tag remote who desc subject url output
	tag=$1
	remote=${2:-glemco}
	# get from branch name (for-linus)
	who=$(git branch --show-current | sed 's/for-\([a-z]\+\)/\1/')
	who=${3:-$who}
	if [ $# -lt 1 ]; then
		echo "Usage $0 tag [remote] [who]"
		echo "Default remote $remote"
		echo "Recipient selected from branch name $who"
		exit 1
	fi
	if ! git send-email --dump-aliases | grep "$who"; then
		echo "No address for $who"
		exit 1
	fi
	# use HEAD~ to make sure we don't fail if the tag is there
	from_tag=$(git describe --no-abbrev HEAD~)
	output="0000-pull-request-$tag"
	subject="[GIT PULL] rv fixes for ${tag#rv-}"
	if desc=$(git config get branch."$(git branch --show-current)".description) ; then
		local title=${desc%%$'\n'*}
		local rest=${desc#*$'\n'}
		# Check if the second line is empty (title format)
		if [[ "${rest%%$'\n'*}" == "" ]]; then
			subject="[GIT PULL] $title"
		fi
		git tag -s "$tag" -m "$desc"
	else
		git tag -s "$tag"
	fi
	if ! git show "$tag" | grep -q "BEGIN PGP SIGNATURE"; then
		echo "Missing signature"
		exit 1
	fi
	url=$(git remote get-url "$remote")
	if [ "$(git rev-list --count "$from_tag...$tag")" -eq 0 ]; then
		echo No commit to pull..
		exit 1
	fi
	git push "$remote" "$tag"
	{
		echo "Subject: $subject"
		echo
		echo "${who^},"
		echo
		git request-pull "$from_tag" "$url" "$tag"  | \
			sed -e "s/tags\/$tag/$tag/" -e "/^${subject//\//\\/}$/{ N; /\n$/d; }"
		echo
		echo "To: $(git send-email --translate-aliases <<< "$who")"
		git log --format='Cc: %aN <%aE>' "$from_tag...$tag" | sort -u
	} > "$output"
	git send-email \
		--confirm always \
		--no-validate \
		--to linux-kernel@vger.kernel.org \
		--to "$who" \
		--to-cmd=true \
		--cc-cmd=true \
		"$output"
}

build() {
	# Build check all patches since upstream
	local args cmd

	args="$*"
	if [ "${args#*-- }" != "$args" ]; then
		cmd=${args#*-- }
		args=${args%--*}
	fi
	if [ "${cmd// }" == "" ]; then
		cmd="yes | make -s -j$(nproc)"
	fi

	# shellcheck disable=SC2086
	git rebase --exec "git log -1 --pretty=%s" --exec "$cmd" $args
}

mail_trailers() {
	# Reword each commit comparing it with the content of an mbx file
	local mbx
	local msg=$1

	if [ -n "$msg" ]; then
		mbx=$(b4 am --no-cover "$msg" 2>&1 | grep "git am" | cut -d/ -f2)
	else
		mbx=$(find . -maxdepth 1 -name \*.mbx | head -n1)
	fi

	trap "rm -rf /tmp/mails \$mbx" EXIT
	rm -rf /tmp/mails
	mkdir /tmp/mails
	git mailsplit -o/tmp/mails "$mbx"
	for mail in /tmp/mails/*; do
		{
			git mailinfo /tmp/msg /tmp/patch < "$mail" \
				| grep "^Subject:" | sed 's/^Subject: //'
			echo
			sed "s/^Signed-off-by: $(git config get user.name) <$(git config get user.email)>//" /tmp/msg
		} > "$mail.msg"
	done
	rm -f /tmp/{msg,patch}

	echo "$mbx preprocessed"

	curmsg() {
		git show -s --format=^%s$ "$@" | grep -rlf- /tmp/mails || echo none
		#grep -rl "^$(git show -s --format=%s "$@")$" /tmp/mails || echo none
	}
	export -f curmsg
	# The editor opens the relevant patch message deleting everything else
	export GIT_EDITOR="vim \$(curmsg) +'set bt=nofile' -d"
	start=$(git log --grep="$(grep Subject "$mbx" | sed 's/.*] //' | head -n1)" --format=%H)
	# Use a specialised editor for the todo, just reword if different
	# shellcheck disable=SC2016
	export GIT_SEQUENCE_EDITOR="awk -i inplace '"'
$1 == "pick" {
	git_msg = mbx_msg = ""
	hash = $2

	cmd = "curmsg " hash
	while ((cmd | getline line) > 0) mbx = line
	close(cmd)
	if (mbx == "none") { print ; next }

	cmd = "git show -s --format=%B " hash
	while ((cmd | getline line) > 0)
        if (line) git_msg = git_msg line "\n"
	close(cmd)

	while ((getline line < mbx) > 0)
        if (line) mbx_msg = mbx_msg line "\n"
	close(mbx)

	if (git_msg != mbx_msg) $1 = "reword"
}
{ print }
'"'"
	git rebase -i "$start~"
}

case "$0" in
	*iterate)
		iterate "$@"
		;;
	*deploy)
		deploy "$@"
		;;
	*grab-patch)
		grab_patch "$@"
		;;
	*prepare-pr)
		prepare_pr "$@"
		;;
	*build)
		build "$@"
		;;
	*mail-trailers)
		mail_trailers "$@"
		;;
esac
