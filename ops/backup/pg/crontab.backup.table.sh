#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

bunx cep -c src -o lib
cron_add "$((RANDOM % 60)) $((RANDOM % 23)) *" $DIR PG_BACKUP_TABLE=1 ./lib/main.js
