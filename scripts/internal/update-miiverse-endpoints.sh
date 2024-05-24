#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

print_info "Setting up Pretendo Miiverse endpoints database..."

create_endpoint_script=$(cat "$git_base_dir/scripts/run-in-container/update-miiverse-endpoints.js")

compose_no_progress up -d miiverse-api

run_verbose docker compose exec miiverse-api node -e "$create_endpoint_script"

print_success "Miiverse endpoints database is set up."
