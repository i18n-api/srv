#!/usr/bin/env bash

# 用管道输入
# password out_path

gpg --symmetric --batch --passphrase "$1" --cipher-algo AES256 -o $2
