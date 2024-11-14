#!/usr/bin/env bash

set -e

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

DIST=../../../dist
. $DIST/ip_li/srv.sh

export PDSH_SSH_ARGS_APPEND="-q -o StrictHostKeyChecking=no -i $DIST/ssh/id_ed25519"

if ! command -v pdsh &>/dev/null; then
  apt-get install -y pdsh
fi

pdsh -w "$SRV_IP_LI" -l root /opt/ops/srv/setup.sh
