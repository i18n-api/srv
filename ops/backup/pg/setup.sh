#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

if [ ! -d "/mnt/backup" ]; then
  git clone git@github.com:wacbk/backup.git /mnt/backup
fi

./run.sh

cron_add '2 19 *' $DIR exe.sh
