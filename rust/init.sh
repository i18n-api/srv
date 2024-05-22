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
      cargo install $pkg --locked
    fi
  done
}

ensure cargo-expand

e ./sh/gen.coffee
