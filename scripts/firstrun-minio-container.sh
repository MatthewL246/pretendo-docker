#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"
minio_init_script=$(cat "$git_base/scripts/run-in-container/minio-init.sh")

docker compose up -d minio

docker compose exec minio sh -c "$minio_init_script"
