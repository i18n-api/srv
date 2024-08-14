#!/usr/bin/env coffee

> path > join resolve
  fs > existsSync rmSync
  @3-/read
  @3-/write
  @3-/nt/load.js
  @3-/mysql2rust/sqlLi.js
  @3-/mysql2rust/rm.js > rm rmPre
  @3-/mysql2rust/gener.js
  @3-/mysql2rust/rust.js

firstUpperCase = (str) =>
  for ch, i in str
    if ch == ch.toUpperCase()
      return i
  return -1

{
  MYSQL_DB
} = process.env

PWD = import.meta.dirname
ROOT = resolve PWD,'../../..'
MOD = join ROOT, 'mod'
DUMP_SQL = join PWD, MYSQL_DB+'.sql'

r = sqlLi read(DUMP_SQL)
nt = load MOD+'.nt'

[GEN, gen] = gener()

if r.length
  mod = new Map
  for i from nt
    p = i.lastIndexOf '/'
    if p
      k = i.slice(p+1)
    else
      k = i
    mdir = join i,'db'
    mod.set k, mdir
    rmPre join MOD,mdir

  DUMP_DIR = join ROOT, 'db'

  rmPre DUMP_DIR

  for [kind,name,sql] from r
    p = firstUpperCase(name)
    if ~p
      prefix = name.slice(0,p)
      dump_name = name.slice(p)
    else
      prefix = dump_name = name

    m = mod.get(prefix)
    if m
      gen kind,name,sql
      write(
        join MOD, m, kind, dump_name+'.sql'
        sql
      )
      continue
    gen kind,name,sql
    write(
      join(DUMP_DIR, kind, name+'.sql')
      sql
    )

write(
  join ROOT, 'rust/lib/m/src/lib.rs'
  rust GEN
)
