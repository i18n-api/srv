#!/usr/bin/env bash

set -ex

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

if ! [ -x "$(command -v dasel)" ]; then
  curl -sSLf "$(curl -sSLf https://api.github.com/repos/tomwright/dasel/releases/latest | grep browser_download_url | grep linux_amd64 | grep -v .gz | cut -d\" -f 4)" -L -o dasel && chmod +x dasel
  mv ./dasel /usr/local/bin/dasel
fi

META=$(dasel -r toml -f ../api/Cargo.toml '.package.join(,:,name,version)' | sed "s/^'//;s/'$//")

set +x # 避免 TZT_PASSWORD 显示到github action 日志
. ../../../dist/GITHUB_TAR.sh
curl -sSf https://raw.githubusercontent.com/i18n-ops/ops/main/setup/deploy.sh | TZT_PASSWORD=$TZT_PASSWORD bash -s -- $META $@
set -x
