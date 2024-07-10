#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This sets up local environment variables in the *.local.env files, including randomly-generated \
secrets. Important external secrets are written to secrets.txt in the root of the repository. By default, the script \
re-uses existing configuration values from .env unless at least one is passed as an argument."
add_option_with_value "-s --server-ip" "server_ip" "ip-address" "The IP address of the Pretendo Network server (must be accessible to the clients)" false
add_option_with_value "-w --wiiu-ip" "wiiu_ip" "ip-address" "The IP address of the Wii U for FTP uploads" false
add_option_with_value "-3 --3ds-ip" "ds_ip" "ip-address" "The IP address of the 3DS for FTP uploads" false
add_option "-n --no-environment" "no_environment" "Disables reading existing configuration values from .env"
add_option "-f --force" "force" "Skip the confirmation prompt and always overwrite existing local environment files"
parse_arguments "$@"

generate_password() {
    length=$1
    head /dev/urandom | LC_ALL=C tr -dc "a-zA-Z0-9" | head -c "$length"
}

generate_hex() {
    length=$1
    head /dev/urandom | LC_ALL=C tr -dc "A-F0-9" | head -c "$length"
}

cd "$git_base_dir/environment"

if [[ -z "$no_environment" ]]; then
    if [[ -f "$git_base_dir/.env" ]]; then
        source $git_base_dir/.env
    fi
    # Copy the configuration from .env if necessary
    : "${server_ip:=${SERVER_IP:-}}"
    : "${wiiu_ip:=${WIIU_IP:-}}"
    : "${ds_ip:=${DS_IP:-}}"
fi

if [[ -z "$server_ip" ]]; then
    print_error "A server IP address was neither passed as an argument nor found in the environment. Please provide one."
    exit 1
fi

if ls ./*.local.env >/dev/null 2>&1; then
    print_warning "Local environment files already exist. They will be overwritten if you continue."
    if [[ -z "$force" ]]; then
        printf "Continue? [y/N] "
        read -r continue
        if [[ "$continue" != "Y" && "$continue" != "y" ]]; then
            echo "Aborting."
            exit 1
        fi
    fi

    print_info "Stopping containers and removing existing local environment files..."
    compose_no_progress down
    rm ./*.local.env
    rm "$git_base_dir/.env"
fi

print_info "Setting up local environment variables..."

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
echo "PN_SPLATOON_ACCOUNT_GRPC_API_KEY=$account_grpc_api_key" >>./splatoon.local.env

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

# Generate passwords, a gRPC API key, and an AES key for the friends server
friends_authentication_password=$(generate_password 32)
echo "PN_FRIENDS_CONFIG_AUTHENTICATION_PASSWORD=$friends_authentication_password" >>./friends.local.env
friends_secure_password=$(generate_password 32)
echo "PN_FRIENDS_CONFIG_SECURE_PASSWORD=$friends_secure_password" >>./friends.local.env
friends_api_key=$(generate_password 32)
echo "PN_FRIENDS_CONFIG_GRPC_API_KEY=$friends_api_key" >>./friends.local.env
echo "PN_WIIU_CHAT_FRIENDS_GRPC_API_KEY=$friends_api_key" >>./wiiu-chat.local.env
echo "PN_MIIVERSE_API_CONFIG_GRPC_FRIENDS_API_KEY=$friends_api_key" >>./miiverse-api.local.env
echo "JUXT_CONFIG_GRPC_FRIENDS_API_KEY=$friends_api_key" >>./juxtaposition-ui.local.env
echo "PN_BOSS_CONFIG_GRPC_FRIENDS_SERVER_API_KEY=$friends_api_key" >>./boss.local.env
friends_aes_key=$(generate_hex 64)
echo "PN_FRIENDS_CONFIG_AES_KEY=$friends_aes_key" >>./friends.local.env

# Generate a Kerberos password for the Wii U Chat server
chat_kerberos_password=$(generate_password 32)
echo "PN_WIIU_CHAT_KERBEROS_PASSWORD=$chat_kerberos_password" >>./wiiu-chat.local.env

# Generate a Kerberos password for the Super Mario Maker server
smm_kerberos_password=$(generate_password 32)
echo "PN_SMM_KERBEROS_PASSWORD=$smm_kerberos_password" >>./super-mario-maker.local.env

# Generate a Kerberos password for the Splatoon server
splat_kerberos_password=$(generate_password 32)
echo "PN_SPLATOON_KERBEROS_PASSWORD=$splat_kerberos_password" >>./splatoon.local.env

# Generate an AES key for the Miiverse servers
miiverse_aes_key=$(generate_hex 64)
echo "PN_MIIVERSE_API_CONFIG_AES_KEY=$miiverse_aes_key" >>./miiverse-api.local.env
echo "JUXT_CONFIG_AES_KEY=$miiverse_aes_key" >>./juxtaposition-ui.local.env

# Generate a gRPC API key for the BOSS server
boss_api_key=$(generate_password 32)
echo "PN_BOSS_CONFIG_GRPC_BOSS_SERVER_API_KEY=$boss_api_key" >>./boss.local.env

# Set up the server IP address
if_verbose print_info "Using server IP address $server_ip."
echo "SERVER_IP=$server_ip" >>"$git_base_dir/.env"
echo "PN_FRIENDS_SECURE_SERVER_HOST=$server_ip" >>./friends.local.env
echo "PN_WIIU_CHAT_SECURE_SERVER_LOCATION=$server_ip" >>./wiiu-chat.local.env
echo "PN_SMM_SECURE_SERVER_HOST=$server_ip" >>./super-mario-maker.local.env
echo "PN_SPLATOON_SECURE_SERVER_HOST=$server_ip" >>./splatoon.local.env

# Get the Wii U IP address
if [[ -n "$wiiu_ip" ]]; then
    if_verbose print_info "Using Wii U IP address $wiiu_ip."
    echo "WIIU_IP=$wiiu_ip" >>"$git_base_dir/.env"
else
    print_info "Skipping Wii U IP address."
fi

# Get the 3DS IP address
if [[ -n "$ds_ip" ]]; then
    if_verbose print_info "Using 3DS IP address $ds_ip."
    echo "DS_IP=$ds_ip" >>"$git_base_dir/.env"
else
    print_info "Skipping 3DS IP address."
fi

# Get the BOSS keys
"$git_base_dir/scripts/get-boss-keys.sh" --write

# Create a list of important secrets
cat >"$git_base_dir/secrets.txt" <<EOF
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

print_success "Successfully set up the environment."

# Some things need to be updated with the new environment variables and secrets,
# but only if the setup script isn't in progress. The MongoDB container replica
# set won't be configured during initial setup, and the scripts will fail.
if [[ -z "${PRETENDO_SETUP_IN_PROGRESS:-}" ]]; then
    print_info "Running necessary container update scripts..."
    "$git_base_dir/scripts/internal/update-postgres-password.sh"
    "$git_base_dir/scripts/internal/update-account-servers-database.sh"
    print_success "Successfully updated the containers with new environment variables."
fi
