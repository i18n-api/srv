#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

source ./sh/pid.sh

watchdir=""
for dir in ./url/*; do
  if [ -L "$dir" ] && [ -d "$dir" ]; then
    watchdir+=" -w $dir"
  fi
done

set -ex

cargo build -p api

echo "cargo exit with $?"

exec direnv exec . watchexec \
  --shell=none \
  --project-origin . \
  -w . \
  -w ../mod \
  $watchdir \
  --exts rs,toml,proto \
  -r \
  -- ./run.sh api
