#!/bin/bash
arch=$(uname -m)
case $arch in
x86_64) FLAG=",+sse2" ;;
*) FLAG="" ;;
esac
export RUSTFLAGS="--cfg reqwest_unstable -C target-feature=+aes$FLAG -Z threads=8"
