#! /bin/sh

set -eu

null_aes_key=""
for _ in $(seq 1 64); do
    null_aes_key="${null_aes_key}0"
done

git_base=$(git rev-parse --show-toplevel)
. "$git_base/environment/system.local.env"
. "$git_base/environment/friends.env"
. "$git_base/environment/friends.local.env"
. "$git_base/environment/wiiu-chat.env"
. "$git_base/environment/wiiu-chat.local.env"

docker compose up -d account

docker compose exec account node /app/dist/create-server-in-database.js reset

docker compose exec account node /app/dist/create-server-in-database.js nex \
    "Friend List" "00003200" "0005001010001C00" "$COMPUTER_IP" \
    "$PN_FRIENDS_AUTHENTICATION_SERVER_PORT" "prod" "$PN_FRIENDS_CONFIG_AES_KEY"
# Wii U Chat server doesn't seem to care about the AES key
docker compose exec account node /app/dist/create-server-in-database.js nex \
    "Wii U Chat" "1005A000" "000500101005A100" "$COMPUTER_IP" \
    "$PN_WIIU_CHAT_AUTHENTICATION_SERVER_PORT" "prod" "$null_aes_key"
