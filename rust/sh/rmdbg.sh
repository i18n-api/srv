#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

cd ..
find . -type f -name "*.rs" | grep -v /tests/ | xargs -I {} sed -i '/dbg\!/d' {}
