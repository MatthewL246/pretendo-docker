#! /bin/sh

set -eu

null_aes_key=""
for _ in $(seq 1 64); do
    null_aes_key="${null_aes_key}0"
done

git_base=$(git rev-parse --show-toplevel)
create_server_script=$(cat "$git_base/scripts/run-in-container/create-server-in-database.js")
create_endpoint_script=$(cat "$git_base/scripts/run-in-container/create-endpoint-in-database.js")
update_pnid_access_level_script=$(cat "$git_base/scripts/run-in-container/update-pnid-access-level-in-database.js")

necessary_environment="friends miiverse-api wiiu-chat"
. "$git_base/environment/system.local.env"
for environment in $necessary_environment; do
    . "$git_base/environment/$environment.env"
    . "$git_base/environment/$environment.local.env"
done

docker compose up -d account

docker compose exec -e COMPUTER_IP="$COMPUTER_IP" \
    -e FRIENDS_PORT="$PN_FRIENDS_AUTHENTICATION_SERVER_PORT" \
    -e FRIENDS_AES_KEY="$PN_FRIENDS_CONFIG_AES_KEY" \
    -e MIIVERSE_AES_KEY="$PN_MIIVERSE_API_CONFIG_AES_KEY" \
    -e WIIU_CHAT_PORT="$PN_WIIU_CHAT_AUTHENTICATION_SERVER_PORT" \
    account node -e "$create_server_script"

printf "Enter the PNID you want to give dev access to: "
read -r dev_pnid
docker compose exec -e PNID="$dev_pnid" account node -e "$update_pnid_access_level_script"

docker compose up -d miiverse-api

docker compose exec miiverse-api node -e "$create_endpoint_script"
