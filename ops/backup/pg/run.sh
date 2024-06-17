#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

if [ ! -d "node_modules" ]; then
  bun i
fi

bunx cep -c src -o lib
exec ./lib/main.js
