#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -e

ROOT=$(dirname $DIR)
cd $ROOT
ENVSH="$(cat ../.env.sh)"
ENVSH=$(printf '%s\n' "$ENVSH" | sed ':a;N;$!ba;s/\n/\\n/g')

rm -rf bin

./build.sh

TMP=$(mktemp -d)

cd $TMP
rm -rf os
rsync -av $DIR/os .
cd os
mkdir -p opt/bin
find $ROOT/bin -type f | xargs -I {} mv {} opt/bin

sed -i "s|ENVSH|$ENVSH|g" opt/bin/srv.sh

set -x

cd $ROOT

META=$(cargo metadata --format-version=1 --no-deps | jq '.packages[] | .name + " " + .version' -r | grep "^srv ")

# NAME=$(echo $META | cut -d ' ' -f1)

export VER=$(echo $META | cut -d ' ' -f2)

LOG=../log/$VER.md

../../dist/encrypt.sh $TMP
