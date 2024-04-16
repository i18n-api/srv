#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

NAME=api
ENV=$DIR/env.sh
WORKDIR=$DIR
. ./sh/service.sh
