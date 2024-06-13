#!/usr/bin/env bash

set -ex
. /etc/profile

export HOME=/root

I18N=$HOME/i18n
SRV=$I18N/srv

cd $I18N/conf
set -o allexport
. $SRV/env.sh
. $SRV/rust/env.sh
set +o allexport

exec /opt/bin/mycron $SRV/mod
