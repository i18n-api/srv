#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

e() {
  direnv exec . $@
}

e ../ops/backup/db/load.coffee
e ../ops/backup/db/dump.sh

APT_URL=api/.url

ensure() {
  for pkg in "$@"; do
    if ! command -v $pkg &>/dev/null; then
      cargo install $pkg
    fi
  done
}

ensure cargo-expand

e ./sh/gen.coffee
cargo fmt

api_dir=$(realpath $DIR/../../api-proto-js)
gen=gen.coffee
if [ -f "$api_dir/$gen" ]; then
  cd $api_dir
  direnv allow
  e ./$gen
fi
