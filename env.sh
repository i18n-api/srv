set -e
DIR=$(dirname "${BASH_SOURCE[0]}")

if echo ":$PATH:" | grep -q ":$DIR/.mise/bin:"; then
  exit 0
fi

# set -x

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

cd $DIR/../conf

RUST_BACKTRACE=short

RUST_LOG=debug,supervisor=warn,hyper=warn,rustls=warn,h2=warn,tower=warn,reqwest=warn,watchexec=warn,fred=info,globset=warn,process_wrap=warn,tungstenite=warn,grep_regex=warn,cargo_machete=warn

_init() {
  cd $1
  shift
  for i in $@; do
    set -o allexport
    . "$i".sh
    set +o allexport
  done
  cd ..
}

_init srv port env
_init env stripe db smtp r ipv6_proxy warn_mail

unset -f _init

set +o allexport

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
