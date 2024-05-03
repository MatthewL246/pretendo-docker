#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"

backup_name="${1-}"
if [ -z "$backup_name" ]; then
    backup_name="backup_$(date +%Y-%m-%dT%H.%M.%S)"
fi

backup_dir="$git_base/backups/$backup_name"
if [ -d "$backup_dir" ]; then
    error "Backup directory $backup_dir already exists."
fi
mkdir -p "$backup_dir"
info "Backing up to $backup_dir"

docker compose up -d mitmproxy-pretendo mongodb postgres minio redis

info "Backing up MongoDB..."
docker compose exec mongodb rm -rf /tmp/backup
docker compose exec mongodb mongodump -o /tmp/backup --quiet
docker compose cp mongodb:/tmp/backup "$backup_dir/mongodb"
docker compose exec mongodb rm -rf /tmp/backup

info "Backing up Postgres..."
docker compose exec postgres sh -c 'pg_dumpall -U "$POSTGRES_USER" --clean' >"$backup_dir/postgres.sql"

info "Backing up MinIO..."
docker compose exec minio sh -c 'mc alias set minio http://minio.pretendo.cc "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"'
docker compose exec minio rm -rf /tmp/backup
docker compose exec minio mkdir -p /tmp/backup
docker compose exec minio mc mirror minio/ /tmp/backup
docker compose cp minio:/tmp/backup "$backup_dir/minio"
docker compose exec minio rm -rf /tmp/backup

info "Backing up Redis..."
docker compose exec redis redis-cli save
docker compose cp redis:/data/dump.rdb "$backup_dir/redis.rdb"

info "Backing up Mitmproxy..."
docker compose cp mitmproxy-pretendo:/home/mitmproxy/.mitmproxy "$backup_dir/mitmproxy"

success "Backup completed successfully."
