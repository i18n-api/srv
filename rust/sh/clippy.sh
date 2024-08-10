#!/usr/bin/env bash

# 检测坏代码风格

DIR=$(realpath $0) && DIR=${DIR%/*/*}
DIR=$(dirname $DIR)
cd $DIR
set -e

if ! hash cargo-clippy 2>/dev/null; then
  rustup component add clippy
fi

egreen() {
  echo -ne "\033[32m$@\033[0m"
}

for rel in $(fd Cargo.toml); do
  cd $DIR

  if grep -q -E '^\[workspace\]$' "$rel"; then
    continue
  fi

  dir=$(dirname $rel)

  if grep -q '^\.' <<<$(basename $dir); then
    continue
  fi

  egreen "→ $dir\n"
  cd $dir
  cargo fmt
  cargo +nightly clippy --quiet --fix -Z unstable-options --allow-no-vcs -- \
    -A clippy::uninit_assumed_init
done
