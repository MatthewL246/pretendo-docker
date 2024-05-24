#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

print_info "Setting up the MinIO container..."

load_dotenv minio.env minio.local.env
minio_init_script=$(cat "$git_base_dir/scripts/run-in-container/minio-init.sh")

compose_no_progress up -d minio
run_command_until_success "Waiting for MinIO to be ready..." 5 \
    docker compose exec minio mc alias set minio http://minio.pretendo.cc "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

run_verbose docker compose exec minio sh -c "$minio_init_script"

print_success "MinIO container is set up."
