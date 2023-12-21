#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/environment/postgres.env"
. "$git_base/environment/postgres.local.env"

docker compose up -d postgres

docker compose exec postgres psql -U "$POSTGRES_USER" -c "ALTER USER $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD';"
