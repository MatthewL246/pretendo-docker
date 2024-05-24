#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This backs up MongoDB, PostgreSQL, MinIO, Redis, and mitmproxy data to the backups directory. Run \
this before doing something risky with the datbases to prevent data loss."
add_positional_argument "backup-name" "backup_name" "Name of the backup directory, defaults to the current date and time" false
parse_arguments "$@"

load_dotenv minio.env minio.local.env postgres.env

if [[ -z "$backup_name" ]]; then
    backup_name="backup_$(date +%Y-%m-%dT%H.%M.%S)"
fi

backup_dir="$git_base_dir/backups/$backup_name"
if [[ -d "$backup_dir" ]]; then
    print_error "Backup directory $backup_dir already exists."
    exit 1
fi
mkdir -p "$backup_dir"
print_info "Backing up to $backup_dir"

print_info "Starting necessary services..."
compose_no_progress up -d mitmproxy-pretendo mongodb postgres minio redis

print_info "Backing up MongoDB..."
run_verbose docker compose exec mongodb rm -rf /tmp/backup
# shellcheck disable=SC2046
run_verbose docker compose exec mongodb mongodump -o /tmp/backup $(if_not_verbose --quiet)
run_verbose compose_no_progress cp mongodb:/tmp/backup "$backup_dir/mongodb"
run_verbose docker compose exec mongodb rm -rf /tmp/backup

print_info "Backing up Postgres..."
docker compose exec postgres pg_dumpall -U "$POSTGRES_USER" --clean >"$backup_dir/postgres.sql"

print_info "Backing up MinIO..."
run_verbose docker compose exec minio mc alias set minio http://minio.pretendo.cc "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
run_verbose docker compose exec minio rm -rf /tmp/backup
run_verbose docker compose exec minio mkdir -p /tmp/backup
run_verbose docker compose exec minio mc mirror minio/ /tmp/backup
run_verbose compose_no_progress cp minio:/tmp/backup "$backup_dir/minio"
run_verbose docker compose exec minio rm -rf /tmp/backup

print_info "Backing up Redis..."
run_verbose docker compose exec redis redis-cli save
run_verbose compose_no_progress cp redis:/data/dump.rdb "$backup_dir/redis.rdb"

print_info "Backing up Mitmproxy..."
run_verbose compose_no_progress cp mitmproxy-pretendo:/home/mitmproxy/.mitmproxy "$backup_dir/mitmproxy"

print_success "Backup completed successfully."
