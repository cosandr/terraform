#!/usr/bin/env sh

[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -e "$0" "$0" "$@" || :

set -e

cd ../../ansible || exit 2

[ ! -f ansible.cfg ] && exit 123

eval "$(jq -r '@sh "HOST=\(.host) QUERY=\(.query)"')"

ansible-inventory --host "$HOST" | jq -r "$QUERY"
