#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This creates a patched Nintendo CA G3 SSL certificate using the SSSL patcher."
parse_arguments "$@"

if [[ ! -f "$git_base_dir/console-files/CACERT_NINTENDO_CA_G3.der" ]]; then
    print_error "Certificate CACERT_NINTENDO_CA_G3.der not found in the console-files directory. Please dump it from \
\"/storage_mlc/sys/title/0005001b/10054000/content/scerts/CACERT_NINTENDO_CA_G3.der\"."
    exit 1
fi

cd "$git_base_dir/repos/SSSL"

print_info "Patching SSL certificate..."

cp "$git_base_dir/console-files/CACERT_NINTENDO_CA_G3.der" .
docker build . -t sssl
docker run -it --rm -v .:/app/certs sssl -g3 /app/certs/CACERT_NINTENDO_CA_G3.der -o /app/certs
cp ./cert-chain.pem "$git_base_dir/console-files"
cp ./ssl-cert-private-key.pem "$git_base_dir/console-files"

print_success "Patched Nintendo CA G3 SSL certificate created successfully in $git_base_dir/console-files"
