#!/usr/bin/env bash

set -ex

exec journalctl -xfeu srv
