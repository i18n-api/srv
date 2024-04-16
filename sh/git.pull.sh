#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -ex

ROOT=$(dirname $DIR)

cd $ROOT
DIR_LI=(rust in conf)

pull() {
  name=$(basename $1)
  name=${name%.git}

  if [ -d "$name" ]; then
    git -C $name pull &
  else
    git clone -b dev --depth=1 $1
  fi
}

pull git@atomgit.com:i18n/rust.git
pull git@atomgit.com:i18n-in/in.git
pull git@atomgit.com:i18n-ol/conf.git

cd $DIR
source mod.sh
mkdir -p mod
cd mod
for i in ${MOD_LI[@]}; do
  pull $i
done

git pull &
wait
