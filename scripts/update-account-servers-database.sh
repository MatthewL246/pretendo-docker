#! /bin/sh

set -eu

null_aes_key=""
for _ in $(seq 1 64); do
    null_aes_key="${null_aes_key}0"
done

git_base=$(git rev-parse --show-toplevel)
necessary_environment="friends miiverse-api wiiu-chat"

. "$git_base/environment/system.local.env"
for environment in $necessary_environment; do
    . "$git_base/environment/$environment.env"
    . "$git_base/environment/$environment.local.env"
done

docker compose up -d account

docker compose exec account node /app/dist/create-server-in-database.js reset

docker compose exec account node /app/dist/create-server-in-database.js nex \
    "Friend List" "00003200" "0005001010001C00" "$COMPUTER_IP" \
    "$PN_FRIENDS_AUTHENTICATION_SERVER_PORT" "dev" "$PN_FRIENDS_CONFIG_AES_KEY"
docker compose exec account node /app/dist/create-server-in-database.js service \
    "Miiverse" "87cd32617f1985439ea608c2746e4610" "000500301001610A" "dev" \
    "$PN_MIIVERSE_API_CONFIG_AES_KEY"
# Wii U Chat server doesn't seem to care about the AES key
docker compose exec account node /app/dist/create-server-in-database.js nex \
    "Wii U Chat" "1005A000" "000500101005A100" "$COMPUTER_IP" \
    "$PN_WIIU_CHAT_AUTHENTICATION_SERVER_PORT" "dev" "$null_aes_key"

# TODO: Script should a PNID's access_level to 3 and server_access_level to dev
# so users can access the servers
