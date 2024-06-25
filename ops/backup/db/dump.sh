#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
export MYSQL_PWD=$MYSQL_PWD
set -xe

mise trust

mysqldump=mysqldump

if [ -f "/usr/bin/mysqldump" ]; then # 不用 OceanBase 自带的 mysqldump , 用 mysql 8 的 mysqldump
  mysqldump=/usr/bin/mysqldump
else
  if command -v apt-get &>/dev/null; then
    apt-get install -y mysql-client
  fi
fi

set +x
cmd="mise exec -- $mysqldump \
  --skip-set-charset \
  --events \
  --skip-add-drop-table \
  --skip-events \
  --compress \
  --set-gtid-purged=OFF \
  --column-statistics=0 \
  --routines \
  -u$MYSQL_USER \
  -P$MYSQL_PORT -d $MYSQL_DB"
echo $cmd
$cmd -h$MYSQL_HOST >/tmp/$MYSQL_DB.sql
set -x
# --column-statistics=0 \
# --compatible=no_table_options

mv /tmp/$MYSQL_DB.sql .

set -x
mise exec -- ./dump.coffee
