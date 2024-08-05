#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
. rust/sh/pid.sh

if [ "$MYSQL_HOST" = "127.0.0.1" ]; then
  lsof -i:$MYSQL_PORT >/dev/null || ../srv.docker/up.sh
fi

cd rust
watchdir=""
for dir in ./url/*; do
  if [ -L "$dir" ] && [ -d "$dir" ]; then
    watchdir+=" -w $dir"
  fi
done

set -ex

echo "cargo exit with $?"

exec mise exec -- watchexec \
  --shell=none \
  --project-origin . \
  -w . \
  -w ../mod \
  $watchdir \
  --exts rs,toml,proto \
  -r \
  -- ./run.sh api
