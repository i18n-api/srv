#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

# if [ -d "../conf" ]; then
#   cd ../conf
#   git pull
#   cd ..
# else
#   cd ..
#   git clone --depth=1 git@github.com:i18n-conf/conf.git conf
#   cd $DIR
# fi

run() {
  direnv allow
  direnv exec . ./$1.sh
}

e() {
  direnv exec . $@
}

cd $DIR/rust

run init

e ./sh/cron.coffee

api_dir=$(realpath $DIR/../proto)
gen=gen.coffee
if [ -f "$api_dir/$gen" ]; then
  cd $api_dir
  direnv allow
  e ./$gen
fi
