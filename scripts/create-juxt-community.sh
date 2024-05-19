#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This creates a community in Juxtaposition, which is required to post anything. It should be run once \
for each community you want to create."
add_positional_argument "name" "name" "The new community's name" true
add_positional_argument "description" "description" "The new community's description" false
add_option_with_value "t --title-ids" "title_ids" "comma-separated-title-IDs" "Comma-separated list of title IDs to include in the community, like \"1,2,3\"" false
add_option_with_value "-i --icon-path" "icon_path" "image-path" "Path to an icon image for the community" false
add_option_with_value "-b --banner-path" "banner_path" "image-path" "Path to a banner image for the community" false
parse_arguments "$@"

create_community_script=$(cat "$git_base_dir/scripts/run-in-container/create-juxt-community.js")

# Clean up title IDs by removing non-alphanumeric characters, but keep commas
title_ids=$(echo "$title_ids" | tr -dc "a-zA-Z0-9,")

docker compose up -d juxtaposition-ui

if [[ -n "$icon_path" ]]; then
    run_verbose_no_errors docker compose cp "$icon_path" juxtaposition-ui:/tmp/icon
fi
if [[ -n "$banner_path" ]]; then
    run_verbose_no_errors docker compose cp "$banner_path" juxtaposition-ui:/tmp/banner
fi

docker compose exec juxtaposition-ui node -e "$create_community_script" "$name" "$description" "$title_ids" "${icon_path:+/tmp/icon}" "${banner_path:+/tmp/banner}"
