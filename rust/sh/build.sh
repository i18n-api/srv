#!/usr/bin/env bash
set -ex
PWD=$(dirname $(realpath $BASH_SOURCE))
. $PWD/flag.sh
# TARGET=$(rustc -vV | sed -n 's|host: ||p')
rm -rf bin/*
mkdir -p bin

cargo build -p $1 \
  --release \
  --out-dir bin \
  -Z unstable-options

cargo sweep --installed
cargo sweep --time 30
