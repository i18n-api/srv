#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if ! command -v cargo-nextest &>/dev/null; then
  cargo install cargo-nextest --locked
fi

direnv exec . cargo nextest run --all-features --nocapture
