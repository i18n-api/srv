#!/usr/bin/env bash

set -e

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

. ../../../conf/env/GITHUB_TAR.sh

curl -sSf https://raw.githubusercontent.com/i18n-ops/ops/main/setup/deploy.sh | TZT_PASSWORD=$TZT_PASSWORD bash -s -- $@
