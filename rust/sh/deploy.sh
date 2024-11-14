#!/usr/bin/env bash

set -ex

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

DIST=$(realpath ../../../dist)

export PDSH_SSH_ARGS_APPEND="-q -o StrictHostKeyChecking=no"

if [ ! -d "~/.ssh" ]; then
  mkdir -p ~/.ssh
  cp $DIST/ssh/id_ed25519 ~/.ssh/
  cp /etc/ops/ansible/ssh_config ~/.ssh/config
  chown 700 ~/.ssh
  chmod 600 ~/.ssh/*
fi

if ! command -v pdsh &>/dev/null; then
  apt-get install -y pdsh
fi

. $DIST/srv_li.sh

ver=$(cat ../api/Cargo.toml | grep "^version" | awk -F'"' '{print $2}')

pdsh -w "$SRV_LI" -l root -R ssh "/opt/ops/srv/setup.sh $ver"
