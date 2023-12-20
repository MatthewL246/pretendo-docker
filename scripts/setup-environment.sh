#!/bin/sh

set -eu

echo "Setting up local environment variables..."

git_base=$(git rev-parse --show-toplevel)
cd "$git_base/environment"

rm ./*.local.env || true

# Generate an AES-256-CBC key for account server tokens
account_aes_key=$(openssl rand -hex 32)
echo "PN_ACT_CONFIG_AES_KEY=$account_aes_key" >>./account.local.env

# Generate master API keys for the account gRPC server
account_api_key_account=$(openssl rand -base64 32)
account_api_key_api=$(openssl rand -base64 32)
echo "PN_ACT_CONFIG_GRPC_MASTER_API_KEY_ACCOUNT=$account_api_key_account" >>./account.local.env
echo "PN_ACT_CONFIG_GRPC_MASTER_API_KEY_API=$account_api_key_api" >>./account.local.env

# Generate secret key for MinIO
minio_secret_key=$(openssl rand -base64 32)
echo "PN_ACT_CONFIG_S3_ACCESS_SECRET=$minio_secret_key" >>./account.local.env
echo "MINIO_ROOT_PASSWORD=$minio_secret_key" >>./minio.local.env

# Generate a password for mongo-express
mongo_express_password=$(openssl rand -base64 32)
echo "ME_CONFIG_BASICAUTH_PASSWORD=$mongo_express_password" >>./mongo-express.local.env

# Generate a password for Postgres
postgres_password=$(openssl rand -base64 32)
echo "POSTGRES_PASSWORD=$postgres_password" >>./postgres.local.env
echo "PN_FRIENDS_CONFIG_DATABASE_URI=postgres://postgres_pretendo:$postgres_password@postgres/friends?sslmode=disable" >>./friends.local.env

# Get the Wii U IP address
printf "Enter your Wii U's IP address: "
read -r wiiu_ip
echo "WIIU_IP=$wiiu_ip" >>./wiiu.local.env

echo "Successfully set up environment."
