#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

# 避免 Cargo.lock 冲突
deltmp

./sh/git.pull.sh
source ../conf/srv/srv.sh
cd rust
./build.sh
./service.sh

FILE_LI="/opt/bin/api.service.sh /opt/bin/api /etc/systemd/system/api.service"

for file in $FILE_LI; do
  pdsh -w "$SRV_LI" -R ssh "mkdir -p $(dirname $file)"
  for srv in $SRV_LI; do
    rsync -av $file $srv:$file
  done
done

cmd="set -ex;cd ~/i18n/conf && git pull;cd ~/i18n/srv && git pull; systemctl daemon-reload && systemctl enable --now api"

pdsh -w "$SRV_LI" -R ssh "bash -c '$cmd'"

for srv in $SRV_LI; do
  ssh $srv "systemctl restart api"
  sleep 5
done
