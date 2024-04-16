#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -e

ROOT=$(dirname $DIR)
cd $ROOT
ENVSH="$(cat env.sh);$(cat ../env.sh)"

rm -rf bin

./build.sh

TMP=$(mktemp -d)

cd $TMP
rm -rf os
rsync -av $DIR/os .
cd os
mkdir -p opt/bin
find $ROOT/bin -type f | xargs -I {} mv {} opt/bin

ENVSH=$(printf '%s\n' "$ENVSH" | sed ':a;N;$!ba;s/\n/\\n/g')
sed -i "s|ENVSH|$ENVSH|g" opt/bin/api.sh

case "$(uname -s)" in
"Darwin")
  OS="apple-darwin"
  ;;
"Linux")
  (ldd --version 2>&1 | grep -q musl) && clib=musl || clib=gun
  OS="unknown-linux-$clib"
  ;;
"MINGW*" | "CYGWIN*")
  OS="pc-windows-msvc"
  ;;
*)
  echo "Unsupported System"
  exit 1
  ;;
esac

ARCH=$(uname -m)

if [[ "$ARCH" == "arm64" || "$ARCH" == "arm" ]]; then
  ARCH="aarch64"
fi

set -x

TZT=$ARCH-$OS.tar.zst

ZSTD_CLEVEL=19 tar -I zstd -cvpf ../$TZT .

cd ..
set +x
. $ROOT/../../conf/env/GITHUB_TAR.sh
$DIR/encrypt.sh $TZT $TZT_PASSWORD
set -x

cd $ROOT
META=$(cargo metadata --format-version=1 --no-deps | jq '.packages[] | .name + " " + .version' -r | grep "^api ")
NAME=$(echo $META | cut -d ' ' -f1)
VER=$(echo $META | cut -d ' ' -f2)

LOG=../log/$VER.md

if [ -f "$LOG" ]; then
  NOTE="-F $LOG"
else
  NOTE="-n $VER"
fi

gh release create -d $VER $NOTE
gh release upload $VER $TMP/$TZT.enc
gh release edit $VER --draft=false
rm -rf $TMP
