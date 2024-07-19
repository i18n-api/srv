#!/usr/bin/env bash

. /etc/profile

export HOME=/root

cd $HOME/i18n/conf

set -o allexport
ENVSH
set +o allexport

exec /opt/bin/api $@
