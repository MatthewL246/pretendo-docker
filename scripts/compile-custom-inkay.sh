#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This compiles a custom version of the Inkay patches that whitelists the mitmproxy certificate for the \
Miiverse applet. It must be run if you want to use Juxt."
add_option "-r --reset" "should_reset" "Resets the Inkay CA certificate to Pretendo's instead of using the mitmproxy certificate"
parse_arguments "$@"

if [[ ! -f "$git_base_dir/.env" ]]; then
    print_error "Missing .env file. Did you run setup-environment.sh?"
    exit 1
fi
source "$git_base_dir/.env"
if [[ -z "${WIIU_IP:-}" ]]; then
    print_warning "Missing environment variable WIIU_IP. Did you specify a Wii U IP address when you ran setup-environment.sh?"
    print_info "Continuing without automatic FTP upload."
fi

cd "$git_base_dir/repos/Inkay"

if [[ -z "$should_reset" ]]; then
    docker compose up -d mitmproxy-pretendo
    run_command_until_success "Waiting for mitmproxy to generate a certificate..." 5 \
        docker compose exec mitmproxy-pretendo ls /home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem

    # Get the current certificate
    run_verbose_no_errors docker compose cp mitmproxy-pretendo:/home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem ./data/ca.pem
else
    git restore ./data/ca.pem
    print_info "Reset Inkay CA certificate."
fi

rm -f ./*.elf ./*.wps

# Set up the Inkay build environment and then build the patches
docker build . -t inkay-build
docker run -it --rm -v .:/app -w /app inkay-build
print_success "Inkay patches built successfully at $(pwd)/Inkay-pretendo.wps"

# Upload the new Inkay patches to the Wii U
if [[ -n "${WIIU_IP:-}" ]]; then
    tnftp -u "ftp://user:pass@$WIIU_IP/fs/vol/external01/wiiu/environments/aroma/plugins/Inkay-pretendo.wps" ./Inkay-pretendo.wps
    print_info "Reboot your Wii U now to apply the new patches."
else
    print_warning "The modified patches were not uploaded to your Wii U because you did not set an IP address."
fi
