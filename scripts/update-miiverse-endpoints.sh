#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
create_endpoint_script=$(cat "$git_base/scripts/run-in-container/update-miiverse-endpoints.js")

docker compose up -d miiverse-api

docker compose exec miiverse-api node -e "$create_endpoint_script"
