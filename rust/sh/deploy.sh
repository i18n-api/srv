#!/usr/bin/env bash

set -e

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

DIST=$(realpath ../../../dist)

export PDSH_SSH_ARGS_APPEND="-q -o StrictHostKeyChecking=no -i $DIST/ssh/id_ed25519 -F /etc/ops/ansible/ssh_config"

if ! command -v pdsh &>/dev/null; then
  sudo apt-get install -y pdsh
fi

. $DIST/srv_li.sh

sudo pdsh -w "$SRV_LI" -l root -R ssh /opt/ops/srv/setup.sh
