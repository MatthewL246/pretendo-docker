#!/bin/sh

set -eu

# Stop all running containers so the new environment variable can be applied
docker compose down

generate_password() {
    length=$1
    tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w "$length" | head -n 1
}

generate_hex() {
    length=$1
    tr -dc 'A-F0-9' </dev/urandom | fold -w "$length" | head -n 1
}

echo "Setting up local environment variables..."

git_base=$(git rev-parse --show-toplevel)
cd "$git_base/environment"

rm ./*.local.env || true

# Generate an AES-256-CBC key for account server tokens
account_aes_key=$(generate_hex 64)
echo "PN_ACT_CONFIG_AES_KEY=$account_aes_key" >>./account.local.env

# Generate master API keys for the account gRPC server
account_api_key_account=$(generate_password 32)
account_api_key_api=$(generate_password 32)
echo "PN_ACT_CONFIG_GRPC_MASTER_API_KEY_ACCOUNT=$account_api_key_account" >>./account.local.env
echo "PN_ACT_CONFIG_GRPC_MASTER_API_KEY_API=$account_api_key_api" >>./account.local.env
echo "PN_FRIENDS_ACCOUNT_GRPC_API_KEY=$account_api_key_account" >>./friends.local.env

# Generate secret key for MinIO
minio_secret_key=$(generate_password 32)
echo "PN_ACT_CONFIG_S3_ACCESS_SECRET=$minio_secret_key" >>./account.local.env
echo "MINIO_ROOT_PASSWORD=$minio_secret_key" >>./minio.local.env

# Generate a password for mongo-express
mongo_express_password=$(generate_password 32)
echo "ME_CONFIG_BASICAUTH_PASSWORD=$mongo_express_password" >>./mongo-express.local.env

# Generate a password for Postgres
postgres_password=$(generate_password 32)
echo "POSTGRES_PASSWORD=$postgres_password" >>./postgres.local.env
echo "PN_FRIENDS_CONFIG_DATABASE_URI=postgres://postgres_pretendo:$postgres_password@postgres/friends?sslmode=disable" >>./friends.local.env

# Generate a Kerberos password and a gRPC API key for the friends server
friends_kerberos_password=$(generate_password 32)
echo "PN_FRIENDS_CONFIG_KERBEROS_PASSWORD=$friends_kerberos_password" >>./friends.local.env
friends_api_key=$(generate_password 32)
echo "PN_FRIENDS_CONFIG_GRPC_API_KEY=$friends_api_key" >>./friends.local.env
friends_aes_key=$(generate_hex 64)
echo "PN_FRIENDS_CONFIG_AES_KEY=$friends_aes_key" >>./friends.local.env

# Get the computer IP address
printf "What is your computer's IP address? It must be accessible to your consoles: "
read -r computer_ip
echo "COMPUTER_IP=$computer_ip" >>./system.local.env
echo "PN_FRIENDS_SECURE_SERVER_HOST=$computer_ip" >>./friends.local.env

# Get the Wii U IP address
printf "Enter your Wii U's IP address: "
read -r wiiu_ip
echo "WIIU_IP=$wiiu_ip" >>./system.local.env

echo "Successfully set up environment."

# Some things need to be updated with the new environment variables and secrets
echo "Running necessary scripts..."
"$git_base"/scripts/update-postgres-password.sh
"$git_base"/scripts/update-account-servers-database.sh
