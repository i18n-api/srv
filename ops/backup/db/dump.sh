#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
export MYSQL_PWD=$MYSQL_PWD
set -xe

mise trust

mysqldump=mariadb-dump

if ! command -v $mysqldump &>/dev/null; then
  if command -v apt-get &>/dev/null; then
    apt-get install -y mariadb-client
  else
    if command -v brew &>/dev/null; then
      brew install mariadb
      brew services stop mariadb || true
    fi
  fi
fi

# 避免 github action 暴露 ip
set +x
cmd="mise exec -- $mysqldump \
  --skip-set-charset \
  --events \
  --skip-add-drop-table \
  --skip-events \
  --compress \
  --routines \
  -d $MYSQL_DB"
echo $cmd
$cmd -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER >/tmp/$MYSQL_DB.sql
set -x
# --column-statistics=0 \
# --compatible=no_table_options

mv /tmp/$MYSQL_DB.sql .

set -x
mise exec -- ./dump.coffee
