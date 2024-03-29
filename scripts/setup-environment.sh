#! /bin/sh

set -eu

generate_password() {
    length=$1
    head /dev/urandom | tr -dc "a-zA-Z0-9" | head -c "$length"
}

generate_hex() {
    length=$1
    head /dev/urandom | tr -dc "A-F0-9" | head -c "$length"
}

# Validate arguments
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <server IP address> [Wii U IP address] [3DS IP address]"
    exit 1
fi
server_ip=$1
wiiu_ip=
if [ "$#" -ge 2 ]; then
    wiiu_ip=$2
fi
ds_ip=
if [ "$#" -ge 3 ]; then
    ds_ip=$3
fi

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"
cd "$git_base/environment"

info "Setting up local environment variables..."

if ls ./*.local.env 1>/dev/null 2>&1; then
    warning "Local environment files already exist. They will be overwritten if you continue."
    printf "Continue? [y/N] "
    read -r continue
    if [ "$continue" != "Y" ] && [ "$continue" != "y" ]; then
        echo "Aborting."
        exit 1
    fi

    docker compose down
    rm ./*.local.env
fi

# Generate an AES-256-CBC key for account server tokens
account_aes_key=$(generate_hex 64)
echo "PN_ACT_CONFIG_AES_KEY=$account_aes_key" >>./account.local.env

# Generate a secret key for account server datastore signatures
account_datastore_secret=$(generate_hex 32)
echo "PN_ACT_CONFIG_DATASTORE_SIGNATURE_SECRET=$account_datastore_secret" >>./account.local.env

# Generate master API keys for the account gRPC server
# The Juxtaposition UI uses the same API key for both the account and API
# servers, so both keys need to be the same
account_grpc_api_key=$(generate_password 32)
echo "PN_ACT_CONFIG_GRPC_MASTER_API_KEY_ACCOUNT=$account_grpc_api_key" >>./account.local.env
echo "PN_ACT_CONFIG_GRPC_MASTER_API_KEY_API=$account_grpc_api_key" >>./account.local.env
echo "PN_FRIENDS_ACCOUNT_GRPC_API_KEY=$account_grpc_api_key" >>./friends.local.env
echo "PN_MIIVERSE_API_CONFIG_GRPC_ACCOUNT_API_KEY=$account_grpc_api_key" >>./miiverse-api.local.env
echo "JUXT_CONFIG_GRPC_ACCOUNT_API_KEY=$account_grpc_api_key" >>./juxtaposition-ui.local.env
echo "PN_BOSS_CONFIG_GRPC_ACCOUNT_SERVER_API_KEY=$account_grpc_api_key" >>./boss.local.env
echo "PN_SMM_ACCOUNT_GRPC_API_KEY=$account_grpc_api_key" >>./super-mario-maker.local.env

# Generate a secret key for MinIO
minio_secret_key=$(generate_password 32)
echo "MINIO_ROOT_PASSWORD=$minio_secret_key" >>./minio.local.env
echo "PN_ACT_CONFIG_S3_ACCESS_SECRET=$minio_secret_key" >>./account.local.env
echo "PN_MIIVERSE_API_CONFIG_S3_ACCESS_SECRET=$minio_secret_key" >>./miiverse-api.local.env
echo "JUXT_CONFIG_AWS_SPACES_SECRET=$minio_secret_key" >>./juxtaposition-ui.local.env
echo "PN_BOSS_CONFIG_S3_ACCESS_SECRET=$minio_secret_key" >>./boss.local.env
echo "PN_SMM_CONFIG_S3_ACCESS_SECRET=$minio_secret_key" >>./super-mario-maker.local.env

# Generate a password for Postgres
postgres_password=$(generate_password 32)
echo "POSTGRES_PASSWORD=$postgres_password" >>./postgres.local.env
echo "PN_FRIENDS_CONFIG_DATABASE_URI=postgres://postgres_pretendo:$postgres_password@postgres/friends?sslmode=disable" >>./friends.local.env
echo "PN_SMM_POSTGRES_URI=postgres://postgres_pretendo:$postgres_password@postgres/super_mario_maker?sslmode=disable" >>./super-mario-maker.local.env

# Generate a Kerberos password, a gRPC API key, and an AES key for the friends
# server
friends_kerberos_password=$(generate_password 32)
echo "PN_FRIENDS_CONFIG_KERBEROS_PASSWORD=$friends_kerberos_password" >>./friends.local.env
friends_api_key=$(generate_password 32)
echo "PN_FRIENDS_CONFIG_GRPC_API_KEY=$friends_api_key" >>./friends.local.env
echo "PN_WIIU_CHAT_FRIENDS_GRPC_API_KEY=$friends_api_key" >>./wiiu-chat.local.env
echo "PN_MIIVERSE_API_CONFIG_GRPC_FRIENDS_API_KEY=$friends_api_key" >>./miiverse-api.local.env
echo "JUXT_CONFIG_GRPC_FRIENDS_API_KEY=$friends_api_key" >>./juxtaposition-ui.local.env
friends_aes_key=$(generate_hex 64)
echo "PN_FRIENDS_CONFIG_AES_KEY=$friends_aes_key" >>./friends.local.env

# Generate a Kerberos password for the Wii U Chat server
chat_kerberos_password=$(generate_password 32)
echo "PN_WIIU_CHAT_KERBEROS_PASSWORD=$chat_kerberos_password" >>./wiiu-chat.local.env

# Generate a Kerberos password for the Super Mario Maker server
smm_kerberos_password=$(generate_password 32)
echo "PN_SMM_KERBEROS_PASSWORD=$smm_kerberos_password" >>./super-mario-maker.local.env

# Generate an AES key for the Miiverse servers
miiverse_aes_key=$(generate_hex 64)
echo "PN_MIIVERSE_API_CONFIG_AES_KEY=$miiverse_aes_key" >>./miiverse-api.local.env
echo "JUXT_CONFIG_AES_KEY=$miiverse_aes_key" >>./juxtaposition-ui.local.env

# Generate a gRPC API key for the BOSS server
boss_api_key=$(generate_password 32)
echo "PN_BOSS_CONFIG_GRPC_BOSS_SERVER_API_KEY=$boss_api_key" >>./boss.local.env

# Set up the server IP address
info "Using server IP address $server_ip."
echo "SERVER_IP=$server_ip" >>./system.local.env
echo "PN_FRIENDS_SECURE_SERVER_HOST=$server_ip" >>./friends.local.env
echo "PN_WIIU_CHAT_SECURE_SERVER_LOCATION=$server_ip" >>./wiiu-chat.local.env
echo "PN_SMM_SECURE_SERVER_HOST=$server_ip" >>./super-mario-maker.local.env

# Get the Wii U IP address
if [ -n "$wiiu_ip" ]; then
    info "Using Wii U IP address $wiiu_ip."
    echo "WIIU_IP=$wiiu_ip" >>./system.local.env
else
    info "Skipping Wii U IP address."
fi

# Get the 3DS IP address
if [ -n "$ds_ip" ]; then
    info "Using 3DS IP address $ds_ip."
    echo "DS_IP=$ds_ip" >>./system.local.env
else
    info "Skipping 3DS IP address."
fi

# Get the BOSS keys
"$git_base"/scripts/get-boss-keys.sh --write

# Create a list of important secrets
cat >"$git_base/secrets.txt" <<EOF
Pretendo Network server secrets
===============================

MinIO root username: minio_pretendo
MinIO root password: $minio_secret_key
Postgres username: postgres_pretendo
Postgres password: $postgres_password
Server IP address: $server_ip
Wii U IP address: ${wiiu_ip:-(not set)}
3DS IP address: ${ds_ip:-(not set)}
EOF

success "Successfully set up environment."

# Some things need to be updated with the new environment variables and secrets,
# but only if the setup script isn't in progress. The MongoDB container replica
# set won't be configured during initial setup, and the scripts will fail.
if [ -z "${PRETENDO_SETUP_IN_PROGRESS+x}" ]; then
    info "Running necessary container update scripts..."
    "$git_base"/scripts/update-postgres-password.sh
    "$git_base"/scripts/update-account-servers-database.sh
    docker compose down
    success "Successfully updated containers with new environment variables."
fi
