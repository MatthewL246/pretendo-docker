#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

minio_init_script=$(cat "$git_base_dir/scripts/run-in-container/minio-init.sh")

docker compose up -d minio

docker compose exec minio sh -c "$minio_init_script"
