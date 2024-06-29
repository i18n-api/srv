#!/usr/bin/env bash
set -e
. /etc/profile

if [ -z "$HOME" ]; then
  export HOME=/root
fi

I18N=$HOME/i18n
SRV=$I18N/srv

cd $I18N/conf
set -o allexport
. $SRV/.env.sh
set +o allexport

set -x
exec timeout 25h /opt/bin/mycron $SRV/mod
