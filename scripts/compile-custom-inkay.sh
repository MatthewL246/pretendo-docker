#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/environment/system.local.env"
cd "$git_base/repos/Inkay"

# Get the current certificate (requires mitmproxy-pretendo to have been run at
# least once)
mitmproxy_cert=$(docker run -it --rm -v pretendo-network_mitmproxy-pretendo-data:/mnt busybox cat /mnt/mitmproxy-ca-cert.pem)
echo "$mitmproxy_cert" | tee ./data/ca.pem

# Set up the Inkay build environment and then build the patches
docker build . -t inkay-build
docker run -it --rm -v .:/app -w /app inkay-build

# Finally, upload the new Inkay patches to the Wii U
ftp -u ftp://user:pass@"$WIIU_IP"/fs/vol/external01/wiiu/environments/aroma/plugins/Inkay-pretendo.wps ./Inkay-pretendo.wps
echo "Reboot your Wii U now to apply the new patches."
