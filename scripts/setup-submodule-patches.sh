#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This configures, resets the contents of, and applies patches to the submodules in the repos directory."
add_option "-u --update-remote" "update_remote" "Updates the submodules from their remotes before applying patches. Only \
use this if you're trying to update the submodules to a newer version than is supported by this project. Patches will \
be applied first with --reject, and if that fails, a 3-way merge will be attempted."
parse_arguments "$@"

cd "$git_base_dir"

print_info "Resetting all submodules..."
git submodule sync >/dev/null
git submodule foreach "git reset --hard" >/dev/null
git submodule foreach "git clean -fd" >/dev/null
git submodule update --init --checkout >/dev/null
if [[ -n "$update_remote" ]]; then
    print_info "Updating submodules from their remotes..."
    git submodule update --remote
fi

print_info "Applying patches to submodules..."
patch_count=0
error_count=0
for dir in "$git_base_dir/patches/"*; do
    if [[ -d "$dir" ]]; then
        subdir=$(basename "$dir")

        cd "$git_base_dir/repos/$subdir"

        for patch in "$git_base_dir/patches/$subdir"/*; do
            if [[ -n "$update_remote" ]]; then
                print_info "Applying patch $patch..."
                if ! git apply --reject "$patch"; then
                    print_error "Failed to apply patch $patch! Attempting 3-way merge..."
                    git add .
                    if ! git apply --3way "$patch"; then
                        print_error "There are merge conflicts with the patch that need to be resolved manually."
                    else
                        print_success "Successfully applied the patch with a 3-way merge. Make sure to re-generate the patch."
                    fi
                    error_count=$((error_count + 1))
                fi
            else
                git apply "$patch"
            fi
            patch_count=$((patch_count + 1))
        done

        git add .
    fi
done

if [[ "$error_count" -gt 0 ]]; then
    print_error "Failed to apply $error_count patches out of $patch_count."
    exit 1
fi
print_success "Successfully applied $patch_count patches."
