#! /bin/sh

set -eu

while ! mc alias set minio http://minio.pretendo.cc "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" >/dev/null 2>&1; do
    echo "Waiting for MinIO to start..."
    sleep 1
done

buckets="pn-cdn pn-boss super-mario-maker"

# Create buckets and allow public access
for bucket in $buckets; do
    if ! mc ls "minio/$bucket" >/dev/null 2>&1; then
        mc mb "minio/$bucket"
        mc anonymous set download "minio/$bucket"
    else
        echo "Bucket $bucket already exists. Skipping..."
    fi
done
