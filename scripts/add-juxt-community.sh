#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
create_community_script=$(cat "$git_base/scripts/run-in-container/create-juxt-community.js")

docker compose up -d juxtaposition-ui

printf "Enter the community name you want to create: "
read -r community_name
printf "Enter the community description: "
read -r community_description
printf "Enter the title IDs you want to add (comma separated, no spaces): "
read -r community_title_ids
printf "Enter a path for the community icon: "
read -r community_icon_path
docker compose cp "$community_icon_path" juxtaposition-ui:/tmp/icon
printf "Enter a path for the community banner: "
read -r community_banner_path
docker compose cp "$community_banner_path" juxtaposition-ui:/tmp/banner

docker compose exec juxtaposition-ui node -e "$create_community_script" "$community_name" "$community_description" "$community_title_ids"
