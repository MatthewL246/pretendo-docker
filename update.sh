#!/usr/bin/env bash

# shellcheck source=./scripts/internal/framework.sh
source "$(dirname "$(realpath "$0")")/scripts/internal/framework.sh"
set_description "This updates the Pretendo environment to the latest version."
parse_arguments "$@"

# Without resetting, Git may have merge conflicts in the submodules because of the applied patches
run_verbose git submodule foreach git reset --hard
git pull

exec "$git_base_dir/setup.sh"
