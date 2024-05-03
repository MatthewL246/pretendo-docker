#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/internal/function-lib.sh"
create_community_script=$(cat "$git_base/scripts/run-in-container/create-juxt-community.js")

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <name> <description> <comma-separated title IDs> [icon image path] [banner image path]"
    exit 1
fi

# Clean up title IDs by removing non-alphanumeric characters, but keep commas
title_ids=$(echo "$3" | tr -dc "a-zA-Z0-9,")

docker compose up -d juxtaposition-ui

icon_path=
if [ "$#" -ge 4 ]; then
    docker compose cp "$4" juxtaposition-ui:/tmp/icon
    icon_path="/tmp/icon"
fi
banner_path=
if [ "$#" -eq 5 ]; then
    docker compose cp "$5" juxtaposition-ui:/tmp/banner
    banner_path="/tmp/banner"
fi

docker compose exec juxtaposition-ui node -e "$create_community_script" "$1" "$2" "$title_ids" "$icon_path" "$banner_path"
