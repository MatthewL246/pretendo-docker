#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
minio_init_script=$(cat "$git_base/config/minio-init.sh")

docker compose up -d minio

# TODO: Find a better way to do this in case Minio takes longer to start up
echo "Waiting for minio to be ready..."
sleep 2
docker compose exec minio sh -c "$minio_init_script"

docker compose down minio
