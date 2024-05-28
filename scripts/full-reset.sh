#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This fully resets the Pretendo environment by deleting all server data."
add_option "-f --force" "force" "Skip the confirmation prompt when resetting"
add_option "--no-backup" "no_backup" "Skip the backup step, very dangerous!"
parse_arguments "$@"

print_warning "This script will fully reset the Pretendo environment by ${term_underline}deleting all server data${term_nounderline}. You will lose your \
PNIDs, NEX accounts, Juxtaposition posts, Super Mario Maker courses, and anything else stored on the server!"
print_warning "This script will also reset the Git repository and all submodules to their original state. Any changes \
you've made will be lost."
if [[ -z "$force" ]]; then
    printf "Continue? [y/N] "
    read -r continue
    if [[ "$continue" != "Y" && "$continue" != "y" ]]; then
        echo "Aborting."
        exit 1
    fi
fi

if [[ -z "$no_backup" ]]; then
    "$git_base_dir/scripts/backup.sh" "pre_reset_$(date +%Y-%m-%dT%H.%M.%S)"
fi

# Resetting stuff...
docker compose down --volumes
rm -f ./environment/*.local.env
# Avoid deleting the .env, as it contains manual configuration
git reset --hard
git submodule foreach "git reset --hard"

print_success "Reset complete. Run setup.sh to set up the environment again."
if [[ -z "$no_backup" ]]; then
    print_info "To restore the backup and undo the reset, use scripts/restore.sh with the backup directory starting with
\"pre_reset\" after running setup.sh."
fi
