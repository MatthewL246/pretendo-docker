#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
minio_init_script=$(cat "$git_base/config/minio-init.sh")

docker compose up -d minio

docker compose exec minio sh -c "$minio_init_script"

docker compose down
