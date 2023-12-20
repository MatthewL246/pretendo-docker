#! /bin/sh

set -eu
git_base=$(git rev-parse --show-toplevel)
. "$git_base/environment/system.local.env"
. "$git_base/environment/friends.env"
. "$git_base/environment/friends.local.env"

docker compose up -d account

docker compose exec account node /app/dist/create-database-server.js nex \
    "Friend List" "00003200" "0005001010001C00" "$COMPUTER_IP" \
    "$PN_FRIENDS_AUTHENTICATION_SERVER_PORT" "prod" "$PN_FRIENDS_CONFIG_AES_KEY"

docker compose down
