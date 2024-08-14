#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

e() {
  mise exec -- $@
}

cd ../ops/backup/db
e ./load.coffee
e ./dump.sh
# if [ "$GITHUB_ACTIONS" == "true" ]; then
# fi

cd $DIR

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
