#! /bin/sh

set -eu

mc alias set minio http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
mc admin info minio

buckets="mii paintings screenshots"

# Create a bucket named mii and allow public access
for bucket in $buckets; do
    mc mb "minio/$bucket"
    mc anonymous set download "minio/$bucket"
done
