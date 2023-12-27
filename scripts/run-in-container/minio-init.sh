#! /bin/sh

set -eu

while ! mc alias set minio http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"; do
    echo "Waiting for MinIO to start..."
    sleep 1
done

mc admin info minio

buckets="pn-cdn"

# Create buckets allow public access
for bucket in $buckets; do
    mc mb "minio/$bucket"
    mc anonymous set download "minio/$bucket"
done
