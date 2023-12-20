#! /bin/sh

set -eu

required_certs="account|nex test|service test|nex friends"

# The datastore keys are required for the account server to start, so this needs
# to run first
docker compose run --rm account generate-keys.js nex datastore

docker compose up -d account

# Split the certs on | while looping
IFS="|"
for cert in $required_certs; do
    # Split the cert again on space to separate the 2 arguments
    IFS=" "
    set -- "$cert"
    docker compose exec account node generate-keys.js $cert
done

docker compose down
