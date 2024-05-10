#!/usr/bin/env bash

# shellcheck source=./framework.sh
source "$(dirname "$(realpath "$0")")/framework.sh"
parse_arguments "$@"

create_endpoint_script=$(cat "$git_base_dir/scripts/run-in-container/update-miiverse-endpoints.js")

docker compose up -d miiverse-api

docker compose exec miiverse-api node -e "$create_endpoint_script"
