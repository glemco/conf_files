#! /usr/bin/sh

######################################################################
# @author      : Gabriele Monaco (32201227+glemco@users.noreply.github.com)
# @file        : cc_cmd
# @created     : Thursday Feb 06, 2025 08:06:20 CET
#
# @description : Get Cc from To: in cover letter
######################################################################

# optional feature
if [ -n "$SKIP_COVER" ]; then
    exit 0
fi

cover_letter=$(grep -z 0000 /proc/$PPID/cmdline | tr -d '\0')

if echo "$1" | grep -q 0000; then
    exit 0
fi

if [ -n "$cover_letter" ]; then
    grep ^To: "$cover_letter" | sed 's/To: //'
fi
