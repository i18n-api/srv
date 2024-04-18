#!/usr/bin/env bash

set -e

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

. ../../../conf/env/GITHUB_TAR.sh
META=$(cargo metadata --format-version=1 --no-deps | jq '.packages[] | .name + ":" + .version' -r | grep "^api:")

curl -sSf https://raw.githubusercontent.com/i18n-ops/ops/main/setup/deploy.sh | TZT_PASSWORD=$TZT_PASSWORD bash -s -- $META $@
