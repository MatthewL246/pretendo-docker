#! /bin/sh

set -eu

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/.function-lib.sh"

info "Resetting all submodules..."
git submodule sync --recursive >/dev/null
git submodule foreach --recursive "git reset --hard" >/dev/null
git submodule update --init --recursive --checkout --force >/dev/null

info "Applying patches to submodules..."
num_patches=0
for dir in "$git_base/patches/"*; do
    if [ -d "$dir" ]; then
        subdir=$(basename "$dir")

        cd "$git_base/repos/$subdir"

        for patch in "$git_base/patches/$subdir"/*; do
            git apply "$patch"
            git add .
            num_patches=$((num_patches + 1))
        done
    fi
done
success "Successfully applied $num_patches patches."
