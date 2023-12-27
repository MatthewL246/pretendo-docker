#! /bin/sh

set -eu

while ! psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c '\l'; do
    echo "Waiting for PostgreSQL to start..."
    sleep 1
done

databases="friends"

for database in $databases; do
    echo "Creating database: $database"
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE DATABASE $database;"
done
