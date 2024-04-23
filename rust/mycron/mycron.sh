#!/usr/bin/env bash

. /etc/profile

export HOME=/root

cd $HOME/i18n/srv

set -o allexport
. env.sh
. rust/env.sh
set +o allexport

exec /opt/bin/mycron $@
