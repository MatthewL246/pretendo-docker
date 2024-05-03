# Scripts

These are important scripts that are used for container setup and administration. Here is a list of each one and what it
does.

- `internal/`: These scripts are consider internal and are run by other scripts.
- `run-in-container/`: These are scripts that, as the name suggests, are run inside containers. They should not be run
  directly, but rather through the other scripts.
- `backup.sh [backup_name]`: This backs up MongoDB, PostgreSQL, MinIO, Redis, and mitmproxy data to the `backups`
  directory. Run this before doing something risky with the datbases to prevent data loss.
- `compile-custom-inkay.sh [--reset]`: This compiles a custom version of the Inkay patches that whitelists the mitmproxy
  certificate for the Miiverse applet. It must be run if you want to use Juxt. Run with `--reset` to reset the
  certificate to Pretendo's official certificate.
- `create-juxt-community.sh <name> <description> <comma-separated title IDs> [icon image path] [banner image path]`:
  This creates a community in Juxtaposition, which is required before posting anything. Specify a name, description, and
  linked title IDs, and optionally set a custom icon and banner image. It should be run once for each community you want
  to create.
- `get-boss-keys.sh [--write]`: This validates the BOSS keys from the dumped key files in `console-files`. Run with
  `--write` to validate the keys and write them to the BOSS server environment variables file.
- `make-pnid-dev.sh <PNID to give developer access>`: This sets the access level of a PNID to developer, which gives it
  administrative permissions across the servers. For example, this makes the PNID's posts "verified" on Juxt. It should
  be run after creating a new PNID that should have administrative permissions.
- `restore.sh <backup_name>`: This restores MongoDB, PostgreSQL, MinIO, Redis, and mitmproxy data from a specific backup
  in the `backups` directory. Note that it also re-runs `setup-environment.sh` to ensure the environment is correct.
- `setup-environment.sh <server IP address> [Wii U IP address] [3DS IP address]`: This sets up local environment
  variables in `*.local.env` files, including randomly-generated secrets. Important external secrets are logged to
  `secrets.txt` in the root of the repository. Specify the server's IP address (must be accessible to the console) and,
  optionally, IP addresses for the consoles for automatic FTP uploads. It should be run whenever this repository is
  updated and new servers are added or if the server or Wii U IP addresses change.
- `setup-submodule-patches.sh`: This sets up the various submodules in`repos` and applies patches to them. It should
  also be run whenever this repository is updated and new servers are added.
- `upload-3ds-files.sh [--reset]`: This uploads required files from `/console-files` to your 3DS to help with connection
  setup. Run with `--reset` to reset the Juxt certificate to Pretendo's official certificate.
