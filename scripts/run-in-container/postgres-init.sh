#!/bin/sh

set -eu

databases="friends super_mario_maker"

for database in $databases; do
    if [ "$(psql -At -U "$POSTGRES_USER" -c "SELECT 1 FROM pg_database WHERE datname='$database'")" = '' ]; then
        echo "Creating database: $database"
        psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE DATABASE $database;"
    fi
done
