#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

create_server_script=$(cat "$git_base_dir/scripts/run-in-container/update-account-servers-database.js")

load_dotenv .env

dotenv_files=("friends" "miiverse-api" "wiiu-chat" "super-mario-maker")
for file in "${dotenv_files[@]}"; do
    load_dotenv "$file.env" "$file.local.env"
done

docker compose up -d account

docker compose exec -e SERVER_IP="$SERVER_IP" \
    -e FRIENDS_PORT="$PN_FRIENDS_AUTHENTICATION_SERVER_PORT" \
    -e FRIENDS_AES_KEY="$PN_FRIENDS_CONFIG_AES_KEY" \
    -e MIIVERSE_AES_KEY="$PN_MIIVERSE_API_CONFIG_AES_KEY" \
    -e WIIU_CHAT_PORT="$PN_WIIU_CHAT_AUTHENTICATION_SERVER_PORT" \
    -e SMM_PORT="$PN_SMM_AUTHENTICATION_SERVER_PORT" \
    account node -e "$create_server_script"
