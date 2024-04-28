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
    pwddir=$(pwd)
    cd $name
    git fetch --all && git reset --hard origin/dev
    cd $pwddir
  else
    git clone -b dev --depth=1 $1
  fi
}

pull git@atomgit.com:i18n/rust.git
pull git@atomgit.com:i18n-in/in.git
pull git@atomgit.com:i18n-ol/conf.git

MOD=$DIR/mod
source $DIR/mod.sh
mkdir -p $MOD
cd $MOD

for i in ${MOD_LI[@]}; do
  pull $i
  gitdir=$(basename $i)
  gitdir=${gitdir%.git}
  cd $gitdir
  find . -name .envrc -print0 | xargs -0 -I {} bash -c "set -ex && cd \$(dirname {}) && direnv allow"
  cd $MOD
done

git pull
