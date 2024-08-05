#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

pid_file="target/debug/$1.pid"

if [ -f "$pid_file" ]; then
  pid=$(cat "$pid_file")
  if ps -p $pid >/dev/null; then
    kill -9 $pid
  fi
fi

exec cargo run -p $1
