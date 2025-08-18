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

case "$0" in
    *iterate)
        iterate "$@"
        ;;
    *deploy)
        deploy "$@"
        ;;
esac
