#!/usr/bin/env coffee

> @3-/uridir
  path > dirname

export PWD = uridir(import.meta)
export ROOT = dirname PWD
process.chdir ROOT
