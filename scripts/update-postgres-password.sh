#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"
if [ ! -f "$git_base/environment/postgres.local.env" ]; then
    error "Missing environment file postgres.local.env. Did you run setup-environment.sh?"
    exit 1
fi
. "$git_base/environment/postgres.env"
. "$git_base/environment/postgres.local.env"

docker compose up -d postgres

while ! docker compose exec postgres psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "\l" >/dev/null 2>&1; do
    echo "Waiting for PostgreSQL to start..."
    sleep 1
done

docker compose exec postgres psql -U "$POSTGRES_USER" -c "ALTER USER $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD';"
