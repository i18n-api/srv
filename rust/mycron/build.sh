#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

export RUSTFLAGS="-Ctarget-feature=+crt-static $RUSTFLAGS"
TARGET=$(rustc -vV | sed -n 's|host: ||p')
rm -rf bin
mkdir -p bin
cargo build \
  --release \
  --out-dir bin \
  -Z unstable-options
