#!/usr/bin/env sh
set -eu
source `dirname $0`/common

target="$HOME/.local/share/typst/packages/${1:-local}/flow/$version"

mkdir -p `dirname "$target"`
rm -rf "$target"
cp -r "$repo" "$target"
