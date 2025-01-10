#!/usr/bin/env sh
set -euo pipefail
source=$(dirname $(realpath $0))
target=~/.local/share/typst/packages/${1:-local}/flow/0.1.0

mkdir -p $(dirname $target)
ln -sf $source $target
