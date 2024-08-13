#!/usr/bin/env coffee

> @w5/uridir
  path > dirname join

export ROOT = dirname uridir(import.meta)
export BAK = join dirname(ROOT), 'data/pg'
export DATA = join(BAK, 'data')
export SCHEMA = join(BAK, 'schema')

