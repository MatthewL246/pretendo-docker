#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

if [[ ! -f "$git_base_dir/environment/postgres.local.env" ]]; then
    print_error "Missing environment file postgres.local.env. Did you run setup-environment.sh?"
    exit 1
fi
source "$git_base_dir/environment/postgres.env"
source "$git_base_dir/environment/postgres.local.env"

docker compose up -d postgres

run_command_until_success "docker compose exec postgres psql -v ON_ERROR_STOP=1 -U '$POSTGRES_USER' -c '\l'" \
    "Waiting for Postgres to be ready..."

# During the first run, this sometimes fails because the entrypoint script
# restarts the server after running the initdb scripts
run_command_until_success "docker compose exec postgres psql -U '$POSTGRES_USER' -c \"ALTER USER $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD';\"" \
    "Failed to change Postgres password, retrying..." 5
