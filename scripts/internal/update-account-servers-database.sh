#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

print_info "Setting up Pretendo account servers database..."

load_dotenv .env
dotenv_files=("friends" "miiverse-api" "wiiu-chat" "super-mario-maker" "splatoon" "minecraft-wiiu" "pikmin-3" "mario-kart-8")
for file in "${dotenv_files[@]}"; do
    load_dotenv "$file.env" "$file.local.env"
done
create_server_script=$(cat "$git_base_dir/scripts/run-in-container/update-account-servers-database.js")

compose_no_progress up -d account

run_verbose docker compose exec -e SERVER_IP="$SERVER_IP" \
    -e FRIENDS_PORT="$PN_FRIENDS_AUTHENTICATION_SERVER_PORT" \
    -e FRIENDS_AES_KEY="$PN_FRIENDS_CONFIG_AES_KEY" \
    -e MIIVERSE_AES_KEY="$PN_MIIVERSE_API_CONFIG_AES_KEY" \
    -e WIIU_CHAT_PORT="$PN_WIIU_CHAT_AUTHENTICATION_SERVER_PORT" \
    -e SMM_PORT="$PN_SMM_AUTHENTICATION_SERVER_PORT" \
    -e SPLATOON_PORT="$PN_SPLATOON_AUTHENTICATION_SERVER_PORT" \
    -e MINECRAFT_PORT="$PN_MINECRAFT_AUTHENTICATION_SERVER_PORT" \
    -e PIKMIN3_PORT="$PN_PIKMIN3_AUTHENTICATION_SERVER_PORT" \
    -e MK8_PORT="$PN_MK8_AUTHENTICATION_SERVER_PORT" \
    account node -e "$create_server_script"

print_success "Account servers database is set up."
