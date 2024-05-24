#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This sets the access level of a PNID to developer, which gives it administrative permissions across the \
servers. For example, this makes the PNID's posts \"verified\" on Juxt. It should be run after creating a new PNID that \
should have administrative permissions."
add_positional_argument "dev-pnid" "dev_pnid" "The PNID to give developer access" true
parse_arguments "$@"

print_info "Giving $dev_pnid developer access..."

update_pnid_access_level_script=$(cat "$git_base_dir/scripts/run-in-container/make-pnid-dev.js")

run_verbose docker compose exec account node -e "$update_pnid_access_level_script" "$dev_pnid"

print_success "Successfully set $dev_pnid's access level to developer."
