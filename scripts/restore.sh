#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"

if [ -z "${1-}" ]; then
    echo "Usage: $0 <backup_name>"
    exit 1
fi

backup_name="$1"
backup_dir="$git_base/backups/$backup_name"
if [ ! -d "$backup_dir" ]; then
    error "Backup directory $backup_dir does not exist."
    exit 1
fi
info "Restoring from $backup_dir"

if [ "${2-}" != "--force" ]; then
    warning "Restoring a backup will overwrite your current Pretendo server data. Backing up your data first is strongly recommended."
    printf "Continue? [y/N] "
    read -r continue
    if [ "$continue" != "Y" ] && [ "$continue" != "y" ]; then
        echo "Aborting."
        exit 1
    fi
fi

info "Stopping unnecessary services..."
docker compose down
docker compose up -d mitmproxy-pretendo mongodb postgres minio redis

info "Restoring MongoDB..."
docker compose exec mongodb rm -rf /tmp/backup
docker compose cp "$backup_dir/mongodb" mongodb:/tmp/backup
docker compose exec mongodb mongorestore /tmp/backup --drop --quiet
docker compose exec mongodb rm -rf /tmp/backup

info "Restoring Postgres..."
# According to the pg_dumpall documentation, dropping and creating the superuser role is expected to cause an error
docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d postgres' <"$backup_dir/postgres.sql" >/dev/null

info "Restoring MinIO..."
docker compose exec minio /bin/sh -c 'mc alias set minio http://minio.pretendo.cc "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"'
docker compose exec minio rm -rf /tmp/backup
docker compose cp "$backup_dir/minio" minio:/tmp/backup
docker compose exec minio mc mirror /tmp/backup minio/ --overwrite --remove
docker compose exec minio rm -rf /tmp/backup

info "Restoring Redis..."
# Redis cannot be running when restoring a dump or it will overwrite the restored dump when it exits
docker compose stop redis
docker compose cp "$backup_dir/redis.rdb" redis:/data/dump.rdb
docker compose start redis

info "Restoring Mitmproxy..."
docker compose cp "$backup_dir/mitmproxy" mitmproxy-pretendo:/home/mitmproxy/.mitmproxy

# The restored backup might be using a different password than what is currently in the .env files
info "Now running the environment setup script to regenerate database passwords."
. "$git_base/environment/system.local.env"
"$git_base/scripts/setup-environment.sh" "$SERVER_IP" "${WIIU_IP-}" "${DS_IP-}"

success "Restore completed successfully."
