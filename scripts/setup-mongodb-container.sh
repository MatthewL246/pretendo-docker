#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
mongodb_init_script=$(cat "$git_base/config/mongodb-init.js")

docker compose up -d mongodb

while ! docker compose exec mongodb mongosh --eval "db.adminCommand('ping')"; do
    echo "Waiting for mongodb to be ready..."
    sleep 1
done

docker compose exec mongodb mongosh --eval "$mongodb_init_script"

docker compose down mongodb
