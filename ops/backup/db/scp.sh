#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

source ../../../../conf/env/ol_vps.sh
scp $MYSQL_DB.sql $OL_VPS:~/i18n/srv/ops/backup/db/
