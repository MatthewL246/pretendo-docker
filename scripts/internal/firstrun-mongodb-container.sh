#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

mongodb_init_script=$(cat "$git_base_dir/scripts/run-in-container/mongodb-init.js")

docker compose up -d mongodb

# This won't work in /docker-entrypoint-initdb.d/ because MongoDB is in a special init state where it will refuse to
# resolve anything but localhost. This needs to be run after it initializes.
# https://github.com/docker-library/mongo/issues/339

run_command_until_success "Waiting for MongoDB to be ready..." 10 \
    docker compose exec mongodb mongosh --eval "db.adminCommand('ping')"

docker compose exec mongodb mongosh --eval "$mongodb_init_script"
