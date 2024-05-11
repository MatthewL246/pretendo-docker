#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

minio_init_script=$(cat "$git_base_dir/scripts/run-in-container/minio-init.sh")

docker compose up -d minio

# sh -c is needed to expand environment variables inside the container
run_command_until_success "docker compose exec minio sh -c 'mc alias set minio http://minio.pretendo.cc \"\$MINIO_ROOT_USER\" \"\$MINIO_ROOT_PASSWORD\"'" \
    "Waiting for MinIO to be ready..." 2

docker compose exec minio sh -c "$minio_init_script"
