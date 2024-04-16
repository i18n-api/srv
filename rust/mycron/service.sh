#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

NAME=$(basename $DIR)
RUST=$(dirname $DIR)
ENV=$RUST/env.sh
ARGS="$(dirname $RUST)/mod"
WORKDIR=$(dirname $(dirname $DIR))
. ../sh/service.sh
