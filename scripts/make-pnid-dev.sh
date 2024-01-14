#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"
update_pnid_access_level_script=$(cat "$git_base/scripts/run-in-container/make-pnid-dev.js")

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <PNID to give developer access>"
    exit 1
fi

docker compose exec account node -e "$update_pnid_access_level_script" "$1"
