#! /bin/sh

set -eu

should_reset=false
if [ "${1-}" = "--reset" ]; then
    should_reset=true
fi

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"
cd "$git_base"

if [ ! -f "$git_base/environment/system.local.env" ]; then
    error "Missing environment file system.local.env. Did you run setup-environment.sh?"
    exit 1
fi
. "$git_base/environment/system.local.env"
if [ -z "${DS_IP+x}" ]; then
    warning "Missing environment variable DS_IP. Did you specify a 3DS IP address when you ran setup-environment.sh?"
    info "Continuing without automatic FTP upload."
fi

if [ "$should_reset" = false ]; then
    docker compose up -d mitmproxy-pretendo

    while ! docker compose exec mitmproxy-pretendo ls /home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem >/dev/null; do
        info "Waiting for mitmproxy to generate a certificate..."
        sleep 1
    done

    # Get the current certificate
    docker compose cp mitmproxy-pretendo:/home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem ./console-files/mitmproxy-ca-cert.pem
else
    info "Reset the Juxt certificate."
fi

# Upload the required files
if [ -n "${DS_IP+x}" ]; then
    if [ "$should_reset" = false ]; then
        ftp -u "ftp://user:pass@$DS_IP:5000/3ds/juxt-prod.pem" ./console-files/mitmproxy-ca-cert.pem
        ftp -u "ftp://user:pass@$DS_IP:5000/gm9/scripts/FriendsSaveSwitcher.gm9" ./console-files/FriendsSaveSwitcher.gm9
        ftp -u "ftp://user:pass@$DS_IP:5000/3ds/ResetFriendsTestAccount.3dsx" ./console-files/ResetFriendsTestAccount.3dsx
    else
        ftp -u "ftp://user:pass@$DS_IP:5000/3ds/juxt-prod.pem" ./console-files/juxt-prod.pem
    fi
    success "Successfully uploaded the required files to your 3DS."
fi
