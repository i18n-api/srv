#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./build.sh

NAME=$(dasel -r toml -f ../api/Cargo.toml '.package.name' | sed "s/^'//;s/'$//")

cp $NAME.sh /opt/bin/

mv bin/$NAME /opt/bin

add_service.sh $NAME
