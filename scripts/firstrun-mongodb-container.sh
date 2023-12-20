#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
mongodb_init_script=$(cat "$git_base/config/mongodb-init.js")

docker compose up -d mongodb

# This won't work in /docker-entrypoint-initdb.d/ because MongoDB is in a
# special init state where it will refuse to resolve anything but localhost.
# This needs to be run after it initializes.
# https://github.com/docker-library/mongo/issues/339

while ! docker compose exec mongodb mongosh --eval "db.adminCommand('ping')"; do
    echo "Waiting for mongodb to be ready..."
    sleep 1
done

docker compose exec mongodb mongosh --eval "$mongodb_init_script"

docker compose down mongodb
