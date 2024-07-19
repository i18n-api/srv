#!/usr/bin/env bash

# 检测坏代码风格

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -ex

if ! hash cargo-clippy 2>/dev/null; then
  rustup component add clippy
fi

cargo fmt
git add -u && git commit -m'.' || true

for dir in $(cargo metadata --format-version=1 --no-deps | jq -r '.packages[] | .manifest_path' | xargs dirname); do
  cd $dir
  cargo +nightly clippy --fix -Z unstable-options --allow-no-vcs -- \
    -A clippy::uninit_assumed_init
done
