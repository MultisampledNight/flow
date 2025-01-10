#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash tomlq
set -eu
source `dirname $0`/common

target=~/.local/share/typst/packages/${1:-local}/flow/0.1.1

mkdir -p `dirname $target`
rm -rf $target
ln -sf $repo $target
