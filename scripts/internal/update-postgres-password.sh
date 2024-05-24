#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

load_dotenv postgres.env postgres.local.env

docker compose up -d postgres

run_command_until_success "Waiting for Postgres to be ready..." 5 \
    docker compose exec postgres psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -l

# During the first run, this sometimes fails because the entrypoint script restarts the server after running the initdb
# scripts
run_command_until_success "Failed to change Postgres password, retrying..." 5 \
    docker compose exec postgres psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "ALTER USER $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD';"
