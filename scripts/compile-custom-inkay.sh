#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)

if [ ! -f "$git_base/environment/system.local.env" ]; then
    echo "Missing environment file system.local.env. Did you run setup-environment.sh?"
    exit 1
fi
. "$git_base/environment/system.local.env"
if [ -z "${WIIU_IP+x}" ]; then
    echo "Missing environment variable WIIU_IP. Did you specify a Wii U IP address when you ran setup-environment.sh?"
    echo "Continuing without automatic FTP upload."
fi

cd "$git_base/repos/Inkay"

docker compose up -d mitmproxy-pretendo

# Get the current certificate
docker compose cp mitmproxy-pretendo:/home/mitmproxy/.mitmproxy/mitmproxy-ca-cert.pem ./data/ca.pem

# Set up the Inkay build environment and then build the patches
docker build . -t inkay-build
docker run -it --rm -v .:/app -w /app inkay-build
echo "Inkay patches built successfully at $(pwd)/Inkay-pretendo.wps"

# Upload the new Inkay patches to the Wii U
if [ -n "${WIIU_IP+x}" ]; then
    ftp -u "ftp://user:pass@$WIIU_IP/fs/vol/external01/wiiu/environments/aroma/plugins/Inkay-pretendo.wps" ./Inkay-pretendo.wps
    echo "Reboot your Wii U now to apply the new patches."
fi
