#!/bin/sh

set -eu

echo "Setting up local environment variables..."

git_base=$(git rev-parse --show-toplevel)
cd "$git_base/environment"

postgres_password=""
if [ -f ./postgres.local.env ]; then
    # Changing the Postgres password doesn't apply to the database if it's
    # already created, and changing now it would break the other servers
    . ./postgres.local.env
    if [ -n "${POSTGRES_PASSWORD-}" ]; then
        echo "Using existing Postgres password"
        postgres_password=$POSTGRES_PASSWORD
    fi
fi

rm ./*.local.env || true

# Generate an AES-256-CBC key for account server tokens
account_aes_key=$(openssl rand -hex 32)
echo "PN_ACT_CONFIG_AES_KEY=$account_aes_key" >>./account.local.env

# Generate master API keys for the account gRPC server
account_api_key_account=$(openssl rand -base64 32)
account_api_key_api=$(openssl rand -base64 32)
echo "PN_ACT_CONFIG_GRPC_MASTER_API_KEY_ACCOUNT=$account_api_key_account" >>./account.local.env
echo "PN_ACT_CONFIG_GRPC_MASTER_API_KEY_API=$account_api_key_api" >>./account.local.env
echo "PN_FRIENDS_ACCOUNT_GRPC_API_KEY=$account_api_key_account" >>./friends.local.env

# Generate secret key for MinIO
minio_secret_key=$(openssl rand -base64 32)
echo "PN_ACT_CONFIG_S3_ACCESS_SECRET=$minio_secret_key" >>./account.local.env
echo "MINIO_ROOT_PASSWORD=$minio_secret_key" >>./minio.local.env

# Generate a password for mongo-express
mongo_express_password=$(openssl rand -base64 32)
echo "ME_CONFIG_BASICAUTH_PASSWORD=$mongo_express_password" >>./mongo-express.local.env

# Generate a password for Postgres
if [ -z "${postgres_password-}" ]; then
    postgres_password=$(openssl rand -base64 32)
fi
echo "POSTGRES_PASSWORD=$postgres_password" >>./postgres.local.env
echo "PN_FRIENDS_CONFIG_DATABASE_URI=postgres://postgres_pretendo:$postgres_password@postgres/friends?sslmode=disable" >>./friends.local.env

# Generate a Kerberos password and a gRPC API key for the friends server
friends_kerberos_password=$(openssl rand -base64 32)
echo "PN_FRIENDS_CONFIG_KERBEROS_PASSWORD=$friends_kerberos_password" >>./friends.local.env
friends_api_key=$(openssl rand -base64 32)
echo "PN_FRIENDS_CONFIG_GRPC_API_KEY=$friends_api_key" >>./friends.local.env
friends_aes_key=$(openssl rand -hex 32)
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
