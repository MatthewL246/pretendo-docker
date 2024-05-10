#!/usr/bin/env bash

set -eu

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This restores MongoDB, PostgreSQL, MinIO, Redis, and mitmproxy data from a specific backup directory. \
Note that it also re-runs setup-environment.sh to ensure the environment is consistent."
add_positional_argument "backup-directory" "backup_dir" "The backup directory to restore from" true
add_option "-f --force" "force" "Skips the restore confirmation prompt"
parse_arguments "$@"

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
docker compose down
docker compose up -d mitmproxy-pretendo mongodb postgres minio redis

print_info "Restoring MongoDB..."
docker compose exec mongodb rm -rf /tmp/backup
docker compose cp "$backup_dir/mongodb" mongodb:/tmp/backup
docker compose exec mongodb mongorestore /tmp/backup --drop --quiet
docker compose exec mongodb rm -rf /tmp/backup

print_info "Restoring Postgres..."
# According to the pg_dumpall documentation, dropping and creating the superuser role is expected to cause an error
print_info "Note: the errors \"current user cannot be dropped\" and \"role ... already exists\" are expected and can be safely ignored."
docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d postgres' <"$backup_dir/postgres.sql" >/dev/null

print_info "Restoring MinIO..."
docker compose exec minio /bin/sh -c 'mc alias set minio http://minio.pretendo.cc "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"'
docker compose exec minio rm -rf /tmp/backup
docker compose cp "$backup_dir/minio" minio:/tmp/backup
docker compose exec minio mc mirror /tmp/backup minio/ --overwrite --remove
docker compose exec minio rm -rf /tmp/backup

print_info "Restoring Redis..."
# Redis cannot be running when restoring a dump or it will overwrite the restored dump when it exits
docker compose stop redis
docker compose cp "$backup_dir/redis.rdb" redis:/data/dump.rdb
docker compose start redis

print_info "Restoring Mitmproxy..."
docker compose cp "$backup_dir/mitmproxy" mitmproxy-pretendo:/home/mitmproxy/.mitmproxy

# The restored backup might be using different secrets than what are currently in the .env files
"$git_base_dir/scripts/setup-environment.sh" --force

print_success "Restore completed successfully."
