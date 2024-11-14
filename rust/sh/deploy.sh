#!/usr/bin/env bash

set -e

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

DIST=../../../dist

export PDSH_SSH_ARGS_APPEND="-q -o StrictHostKeyChecking=no"

if ! command -v pdsh &>/dev/null; then
  sudo apt-get install -y pdsh
fi

if [ ! -d "~/.ssh" ]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
fi

if [ ! -f "~/.ssh/config" ]; then
  cp /etc/ops/ansible/ssh_config ~/.ssh/config
  chmod 600 ~/.ssh/config
fi

if [ ! -f "~/.ssh/id_ed25519" ]; then
  cp $DIST/ssh/id_ed25519 ~/.ssh/id_ed25519
  chmod 600 ~/.ssh/id_ed25519
fi

. $DIST/srv_li.sh

sudo pdsh -w "$SRV_LI" -l root -R ssh /opt/ops/srv/setup.sh
