#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./build.sh

if ! command -v dasel &>/dev/null; then
  cd /tmp
  curl -sSLf "$(curl -sSLf https://api.github.com/repos/tomwright/dasel/releases/latest | grep browser_download_url | grep linux_amd64 | grep -v .gz | cut -d\" -f 4)" -L -o dasel && chmod +x dasel
  mv ./dasel /usr/local/bin/dasel
  cd $DIR
fi

NAME=$(dasel -r toml -f Cargo.toml '.package.name' | sed "s/^'//;s/'$//")

cp $NAME.sh /opt/bin/

mv bin/$NAME /opt/bin

add_service.sh $NAME
