#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if ! [ -x "$(command -v cargo-v)" ]; then
  cargo install cargo-v
fi

cargo v patch -y
git add -u
git commit -m. || true
git push
cargo publish
