# Scripts

These are important scripts that are used for container setup and
administration. Here is a list of each one and what it does.

- `run-in-container/`: These are scripts that, as the name suggests, are run
  inside containers. They should not be run directly, but rather through the
  other scripts.
- `compile-custom-inkay.sh`: This compiles a custom version of the Inkay patches
  that whitelists the mitmproxy certificate for the Miiverse applet. It must be
  run after creating new mitmproxy certificates (for example, if the mitmproxy
  data volume was deleted) if you want to use Juxt.
- `create-juxt-community.sh`: This creates a community in Juxtaposition, which
  is required before posting anything. It also allows setting a custom icon and
  banner image. It should be run for whatever communities you want to use.
- `firsrun-*.sh`: These are scripts that are run on the first run of certain
  containers. They are run automatically by the main setup script and shouldn't
  be used after that.
- `make-pnid-dev.sh`: This sets the access level of a PNID to developer, which
  gives it administrative permissions across the servers. For example, this
  makes the PNID's posts "verified" on Juxt. It should be run after creating a
  new PNID that should have administrative permissions.
- `setup-environment.sh`: This sets up local environment variables in
  `*.local.env` files, such as randomly-generated secrets. Important external
  secrets are logged to `secrets.txt` in the root of the repository. It should
  be run whenever this repository is updated and new servers are added or if the
  server or Wii U IP addresses change.
- `setup-submodule-patches.sh`: This sets up the various submodules in`repos`
  and applies patches to them. It should also be run whenever this repository is
  updated and new servers are added.
- `update-account-servers-database.sh`: This updates the database of account
  servers. It should be run whenever a new account server is added to this
  repository or the server IP address changes, and it is automatically run by
  `setup-environment.sh`.
- `update-miiverse-endpoints.sh`: This updates the Miiverse endpoints for the
  discovery API server. It currently uses hard-coded values, so it should not be
  neccesary to run it.
- `update-postgres-password.sh`: This updates the password for the PostgreSQL
  database. It should be run whenever the password is regenerated, and it is
  automatically run by `setup-environment.sh`.
