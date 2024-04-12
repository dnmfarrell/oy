#!/bin/sh

. "./tests/tap.sh" || (printf "failed to source tap.sh\n" && exit 1)
. "./oy" || (printf "failed to source oy\n" && exit 1)

tap_ok "$?" 'source oy'
tap_end
