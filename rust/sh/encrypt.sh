#!/usr/bin/env bash

# 用管道输入
# password_file out_path

cat $2 | exec gpg --symmetric --batch --passphrase-file "$1" --cipher-algo AES256 -o $2.gpg
