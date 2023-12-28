#! /bin/sh

set -eu

should_reset=false
if [ "${1-}" = "--reset" ]; then
    should_reset=true
fi

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"

if [ ! -f "$git_base/environment/system.local.env" ]; then
    error "Missing environment file system.local.env. Did you run setup-environment.sh?"
    exit 1
fi
. "$git_base/environment/system.local.env"
if [ -z "${WIIU_IP+x}" ]; then
    warning "Missing environment variable WIIU_IP. Did you specify a Wii U IP address when you ran setup-environment.sh?"
    info "Continuing without automatic FTP upload."
fi

cd "$git_base/repos/Inkay"

if [ "$should_reset" = false ]; then
    docker compose up -d mitmproxy-pretendo
    while ! docker compose exec mitmproxy-pretendo ls /home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem >/dev/null; do
        info "Waiting for mitmproxy to generate a certificate..."
        sleep 1
    done

    # Get the current certificate
    docker compose cp mitmproxy-pretendo:/home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem ./data/ca.pem
else
    git restore ./data/ca.pem
    info "Reset Inkay CA certificate."
fi

rm ./*.elf ./*.wps || true

# Set up the Inkay build environment and then build the patches
docker build . -t inkay-build
docker run -it --rm -v .:/app -w /app inkay-build
success "Inkay patches built successfully at $(pwd)/Inkay-pretendo.wps"

# Upload the new Inkay patches to the Wii U
if [ -n "${WIIU_IP+x}" ]; then
    ftp -u "ftp://user:pass@$WIIU_IP/fs/vol/external01/wiiu/environments/aroma/plugins/Inkay-pretendo.wps" ./Inkay-pretendo.wps
    info "Reboot your Wii U now to apply the new patches."
fi
