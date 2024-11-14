#!/usr/bin/env bash
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -ex
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=git

up() {
  cargo update
  cargo upgrade -i --recursive --verbose
}

upgrade() {
  cd $1
  up || up || up
}

MOD=$(realpath $DIR/../..)/mod

for fp in $(find $MOD -type f -name Cargo.toml); do
  upgrade $(dirname $fp)
done

upgrade $DIR
