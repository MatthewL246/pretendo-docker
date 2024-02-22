#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"
create_server_script=$(cat "$git_base/scripts/run-in-container/update-account-servers-database.js")

if [ ! -f "$git_base/environment/system.local.env" ]; then
    error "Missing environment file system.local.env. Did you run setup-environment.sh?"
    exit 1
fi
. "$git_base/environment/system.local.env"

necessary_environment_files="friends miiverse-api wiiu-chat super-mario-maker"
for environment in $necessary_environment_files; do
    if [ ! -f "$git_base/environment/$environment.local.env" ]; then
        error "Missing environment file $environment.local.env. Did you run setup-environment.sh?"
        exit 1
    fi
    . "$git_base/environment/$environment.env"
    . "$git_base/environment/$environment.local.env"
done

docker compose up -d account

docker compose exec -e SERVER_IP="$SERVER_IP" \
    -e FRIENDS_PORT="$PN_FRIENDS_AUTHENTICATION_SERVER_PORT" \
    -e FRIENDS_AES_KEY="$PN_FRIENDS_CONFIG_AES_KEY" \
    -e MIIVERSE_AES_KEY="$PN_MIIVERSE_API_CONFIG_AES_KEY" \
    -e WIIU_CHAT_PORT="$PN_WIIU_CHAT_AUTHENTICATION_SERVER_PORT" \
    -e SMM_PORT="$PN_SMM_AUTHENTICATION_SERVER_PORT" \
    account node -e "$create_server_script"
