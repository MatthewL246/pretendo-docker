#!/bin/sh

set -eu

echo "Resetting all submodules..."
git submodule sync --recursive
git submodule foreach --recursive "git reset --hard"
git submodule update --init --recursive --checkout --force

git_base=$(git rev-parse --show-toplevel)

echo "Applying patches..."
num_patches=0
for dir in "$git_base/patches/"*; do
    if [ -d "$dir" ]; then
        subdir=$(basename "$dir")

        cd "$git_base/repos/$subdir"

        for patch in "$git_base/patches/$subdir"/*; do
            echo "Applying patch $subdir/$(basename "$patch")..."
            git apply "$patch"
            git add .
            num_patches=$((num_patches + 1))
        done
    fi
done
echo "Successfully applied $num_patches patches."
