#!/usr/bin/env bash

set -o allexport
if [ ! -s ".env" ]; then
  ln -s ../../../../conf/api/.env .
fi

source .env

# if [[ $(uname -s) == "Linux" ]]; then
#   BACKUP=/mnt/backup/pg
#   # export PG_HOST=127.0.0.1
#   # export PG_URI=$PG_USER:$PG_PASSWORD@$PG_HOST:$PG_PORT/$PG_DB
# else
#   BACKUP=$DIR/dump
# fi
set +o allexport
