#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

branch=$(git symbolic-ref --short -q HEAD)
gci
git pull
msg=$(git log -1 --pretty=format:'%B' $branch)

if ! [ -z "$1" ]; then
  gme $@
fi

cd rust/api
touch Cargo.lock
cargo v patch -y
if [ "$branch" != "main" ]; then
  git push
  git checkout main
  git merge $branch
fi

git push
msg=$(git log -1 --pretty=format:'%B' $branch)
git push github $msg main
git checkout $branch
