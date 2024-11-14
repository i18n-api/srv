#!/usr/bin/env bash

# 用管道输入
# password out_path

cat $2 | exec gpg --symmetric --batch --passphrase "$1" --cipher-algo AES256 -o $2.gpg
