#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
export MYSQL_PWD=$MYSQL_PWD
set -e

direnv allow

mysqldump=mysqldump

if [ -f "/usr/bin/mysqldump" ]; then # 不用 OceanBase 自带的 mysqldump , 用 mysql 8 的 mysqldump
  mysqldump=/usr/bin/mysqldump
else
  if command -v apt-get &>/dev/null; then
    apt-get install -y mysql-client
  fi
fi
direnv exec . $mysqldump \
  --skip-set-charset \
  --events \
  --compress \
  --skip-add-drop-table \
  --set-gtid-purged=OFF \
  --column-statistics=0 \
  --routines \
  -u"$MYSQL_USER" \
  -P$MYSQL_PORT -h$MYSQL_HOST -d "$MYSQL_DB" >/tmp/$MYSQL_DB.sql && mv /tmp/$MYSQL_DB.sql .
# --column-statistics=0 \
# --compatible=no_table_options \

set -x
direnv exec . ./dump.coffee
