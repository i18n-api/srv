#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

bunx cep -c src -o lib
./lib/load.js
# if [[ $PG_URI != *-dev* ]]; then
#   echo "数据库名称不包含 -dev 不执行，小心误操作"
#   exit 0
# fi
#
# load_schema() {
#   psql postgres://$1 -c "DROP SCHEMA $2 CASCADE" || true
#   psql postgres://$1 <./dump/art-ol/art-ol/table/$2.sql
#   zstd -qcd ./data/art-ol/$2.zstd | pg_restore --disable-triggers -d "postgres://$1"
# }
#
# load() {
#   load_schema $1 bot
#   load_schema $1 img
# }
#
# load $PG_URI
