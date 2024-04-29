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

cd $DIR/rust

run init

direnv exec . ./sh/cron.coffee
