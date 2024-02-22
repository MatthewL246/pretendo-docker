#! /bin/sh

set -eu

databases="friends super_mario_maker"

for database in $databases; do
    echo "Creating database: $database"
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE DATABASE $database;"
done
