#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

. .env.sh

if [[ $(uname -s) == "Linux" ]]; then
  export PG_HOST=127.0.0.1
  export PG_URI=$PG_USER:$PG_PASSWORD@$PG_HOST:$PG_PORT/$PG_DB
fi

if [ -f "./lib/main.js" ]; then
  exec ./lib/main.js
else
  exec ./run.sh
fi
