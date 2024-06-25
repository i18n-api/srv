set -e
DIR=$(dirname "${BASH_SOURCE[0]}")

if echo ":$PATH:" | grep -q ":$DIR/.mise/bin:"; then
  exit 0
fi
set -o allexport
if command -v rg &>/dev/null; then
  if [ -z "$EXE_RG" ]; then
    EXE_RG=$(type -P rg)
  fi
fi

if command -v fd &>/dev/null; then
  if [ -z "$EXE_FD" ]; then
    EXE_FD=$(which fd)
  fi
fi
set +o allexport

cd $DIR/../conf
. $DIR/.env.sh

cd $DIR

. rust/sh/flag.sh
if ! [ -d node_modules ]; then
  bun i
fi

rust_api_url_cargo=rust/api/.url/Cargo.toml
if ! [ -f "$rust_api_url_cargo" ]; then
  src=$(dirname $rust_api_url_cargo)/src
  mkdir -p $src
  touch $src/lib.rs
  echo -e '[package]\nname = "url"' >$rust_api_url_cargo
fi
