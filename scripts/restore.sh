#!/usr/bin/env bash

set -eu

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This restores MongoDB, PostgreSQL, MinIO, Redis, and mitmproxy data from a specific backup directory. \
Note that it also re-runs setup-environment.sh to ensure the environment is consistent."
add_positional_argument "backup-directory" "backup_dir" "The backup directory to restore from" true
add_option "-f --force" "force" "Skips the restore confirmation prompt"
parse_arguments "$@"

load_dotenv minio.env minio.local.env postgres.env

if [[ ! -d "$backup_dir" ]]; then
    print_error "Backup directory $backup_dir does not exist."
    exit 1
fi
print_info "Restoring from $backup_dir"

print_warning "Restoring a backup will overwrite your current Pretendo server data. Backing up your data first is strongly recommended."
if [[ -z "$force" ]]; then
    printf "Continue? [y/N] "
    read -r continue
    if [[ "$continue" != "Y" && "$continue" != "y" ]]; then
        echo "Aborting."
        exit 1
    fi
fi

print_info "Stopping unnecessary services..."
compose_no_progress down
print_info "Starting necessary services..."
compose_no_progress up -d mitmproxy-pretendo mongodb postgres minio redis mailpit

print_info "Restoring MongoDB..."
run_verbose docker compose exec mongodb rm -rf /tmp/backup
run_verbose compose_no_progress cp "$backup_dir/mongodb" mongodb:/tmp/backup
# shellcheck disable=SC2046
run_verbose docker compose exec mongodb mongorestore /tmp/backup --drop $(if_not_verbose --quiet)
run_verbose docker compose exec mongodb rm -rf /tmp/backup

print_info "Restoring Postgres..."
# According to the pg_dumpall documentation, dropping and creating the superuser role is expected to cause an error
run_verbose_no_errors docker compose exec -T postgres psql -U "$POSTGRES_USER" -d postgres <"$backup_dir/postgres.sql"

print_info "Restoring MinIO..."
run_verbose docker compose exec minio mc alias set minio http://minio.pretendo.cc "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
run_verbose docker compose exec minio rm -rf /tmp/backup
run_verbose compose_no_progress cp "$backup_dir/minio" minio:/tmp/backup
run_verbose docker compose exec minio mc mirror /tmp/backup minio/ --overwrite --remove
run_verbose docker compose exec minio rm -rf /tmp/backup

print_info "Restoring Redis..."
# Redis cannot be running when restoring a dump or it will overwrite the restored dump when it exits
run_verbose compose_no_progress stop redis
run_verbose compose_no_progress cp "$backup_dir/redis.rdb" redis:/data/dump.rdb

print_info "Restoring Mitmproxy..."
# Mitmproxy cannot be running when restoring a backup or it will continue using its new certificate
run_verbose compose_no_progress stop mitmproxy-pretendo
# Don't restore the config file because copying a broken relative symlink causes an error
rm -f "$backup_dir/mitmproxy/config.yaml"
run_verbose compose_no_progress cp "$backup_dir/mitmproxy/." mitmproxy-pretendo:/home/mitmproxy/.mitmproxy

print_info "Restoring Mailpit..."
run_verbose compose_no_progress stop mailpit
run_verbose compose_no_progress cp "$backup_dir/mailpit.db" mailpit:/data/mailpit.db

# The restored backup might be using different secrets than what are currently in the .env files
"$git_base_dir/scripts/setup-environment.sh" --force

print_success "Restore completed successfully."
