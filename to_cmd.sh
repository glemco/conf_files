#! /usr/bin/sh

######################################################################
# @author      : Gabriele Monaco (32201227+glemco@users.noreply.github.com)
# @file        : to_cmd
# @created     : Wednesday Feb 05, 2025 15:38:12 CET
#
# @description : Get To from body and maintainers file
######################################################################

patch=$1

# some subsystems have further divisions get_maintainer doesn't understand
# try to ignore those in the automatic selection. E.g. :
# M: Foo Bar <foo@bar.com> (SUB_SUBSYSTEM)
get_blacklisted() {
    if [ -f MAINTAINERS ]; then
        grep 'M:\s[a-Z ]\+<[a-z@.]\+> ([^)]\+)' MAINTAINERS | \
            sed 's/ (.*//' | sed 's/M:\s//'
    fi
}

# parse from the patch
grep ^To: "$patch" | sed 's/To: //'

# the cover letter is not a patch
if echo "$patch" | grep -q 0000; then
    exit 0
fi

# add only lists and maintainers by default
if [ -x scripts/get_maintainer.pl ]; then
    temp_file=$(mktemp)
    nom=$([ -n "$NOMAINT" ] && echo --nom || echo --m)
    fixes=$([ -n "$NOFIX" ] && echo --nofixes || echo --fixes)
    rolestats=$([ -n "$VERBOSE" ] && echo --rolestats || echo --norolestats)
    keywords=$([ -n "$KEYWORDS" ] && echo --keywords || echo --nokeywords)
    get_blacklisted > "$temp_file"
    scripts/get_maintainer.pl --nor "$nom" --nogit --nogit-fallback "$fixes" "$rolestats" "$keywords" "$patch" | \
        grep -v -f "$temp_file"
    rm -f "$temp_file"
fi
