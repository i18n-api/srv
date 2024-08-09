#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e

source ../rclone_load.sh

name=$1
uri=$2
schema=$3

load() {
  for s in $schema; do
    echo "→ 加载表 $s 数据"
    pv $fp/$s.zstd | zstd -d -c | pg_restore --disable-triggers -d "$uri"
  done
}

rclone_load pg.$name
