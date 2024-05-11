#!/bin/sh

set -eu

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
