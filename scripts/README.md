# Scripts

These are important scripts that are used for container setup and
administration. Here is a list of each one and what it does.

- `run-in-container/`: These are scripts that, as the name suggests, are run
  inside containers. They should not be run directly, but rather through the
  other scripts.
- `compile-custom-inkay.sh [--reset]`: This compiles a custom version of the
  Inkay patches that whitelists the mitmproxy certificate for the Miiverse
  applet. It must be run if you want to use Juxt. Run with `--reset` to reset
  the certificate to Pretendo's official certificate.
- `create-juxt-community.sh <name> <description> <comma-separated title IDs> [icon image path] [banner image path]`:
  This creates a community in Juxtaposition, which is required before posting
  anything. Specify a name, description, and linked title IDs, and optionally
  set a custom icon and banner image. It should be run once for each community
  you want to create.
- `firstrun-*.sh`: These are scripts that are run on the first run of certain
  containers. They are run automatically by the main setup script and shouldn't
  be used after that.
- `get-boss-keys.sh [--write]`: This validates the BOSS keys from the dumped key
  files in `console-files`. Run with `--write` to validate the keys and write
  them to the BOSS server environment variables file.
- `make-pnid-dev.sh <PNID to give developer access>`: This sets the access level
  of a PNID to developer, which gives it administrative permissions across the
  servers. For example, this makes the PNID's posts "verified" on Juxt. It
  should be run after creating a new PNID that should have administrative
  permissions.
- `setup-environment.sh <server IP address> [Wii U IP address] [3DS IP address]`:
  This sets up local environment variables in `*.local.env` files, including
  randomly-generated secrets. Important external secrets are logged to
  `secrets.txt` in the root of the repository. Specify the server's IP address
  (must be accessible to the console) and, optionally, IP addresses for the
  consoles for automatic FTP uploads. It should be run whenever this repository
  is updated and new servers are added or if the server or Wii U IP addresses
  change.
- `setup-submodule-patches.sh`: This sets up the various submodules in`repos`
  and applies patches to them. It should also be run whenever this repository is
  updated and new servers are added.
- `update-account-servers-database.sh`: This updates the database of account
  servers. It should be run whenever a new account server is added to this
  repository or the server IP address changes, and it is automatically run by
  `setup-environment.sh`.
- `update-miiverse-endpoints.sh`: This updates the Miiverse endpoints for the
  discovery API server. It currently uses hard-coded values, so it should not be
  neccesary to run it again.
- `update-postgres-password.sh`: This updates the password for the PostgreSQL
  database. It should be run whenever the password is regenerated, and it is
  automatically run by `setup-environment.sh`.
- `upload-3ds-files.sh [--reset]`: This uploads required files from
  `/console-files` to your 3DS to help with connection setup. Run with `--reset`
  to reset the Juxt certificate to Pretendo's official certificate.
