#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

bunx cep -c src -o lib
cd ./lib
./main.js
