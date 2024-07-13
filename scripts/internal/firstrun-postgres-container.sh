#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

print_info "Setting up the Postgres container..."

load_dotenv postgres.env postgres.local.env
postgres_init_script=$(cat "$git_base_dir/scripts/run-in-container/postgres-init.sh")

compose_no_progress up -d postgres
run_command_until_success "Waiting for Postgres to be ready..." 5 \
    docker compose exec postgres psql -U "$POSTGRES_USER" -c "\\l"

run_verbose docker compose exec postgres sh -c "$postgres_init_script"

print_success "Postgres container is set up."
