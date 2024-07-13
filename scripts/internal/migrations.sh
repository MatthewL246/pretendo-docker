#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

print_info "Running migrations..."

load_dotenv postgres.env postgres.local.env

compose_no_progress up -d postgres
if [[ $(docker compose exec postgres psql -At -U "$POSTGRES_USER" -d friends -c "SELECT 1 FROM information_schema.schemata WHERE schema_name = '3ds';") = "1" ]]; then
    print_info "Migrating friends to the nex-go rewrite..."
    migration=$(cat "$git_base_dir/scripts/run-in-container/friends-nex-go-rewrite-migration.sql")
    # shellcheck disable=SC2046
    docker compose exec postgres psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d friends -c "$migration" $(if_not_verbose --quiet)
fi

print_success "Migrations are complete."
