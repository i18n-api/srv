#!/usr/bin/env coffee

> ./conf.coffee > ROOT
  @3-/walk
  @3-/dbq > $e
  @3-/nt/load
  fs > existsSync
  path > dirname join
  zx/globals:

$.verbose = true

BASE = dirname(ROOT)
MOD = join BASE, 'mod'

load_nt = (dir, nt)=>
  pli = []
  vli = []

  for [sh, minute_timeout] from Object.entries nt
    [minute, timeout] = minute_timeout.split(' ').map (i)=>Number.parseInt(i)
    console.log dir,sh,'minute',minute,'timeout',timeout
    cdir = join(MOD, dir, 'cron')
    cd cdir
    if existsSync join(cdir, 'package.json')
      if not existsSync join(cdir, 'node_modules')
        await $"bun i"
    await $"timeout #{timeout} mise exec -- ./#{sh}"
    # await $"mise trust && timeout #{timeout} mise exec -- ./#{sh}"
    pli.push '(?,?,?,?)'
    vli.push dir, sh, minute, timeout

  if not vli.length
    return
  $e(
    "INSERT IGNORE INTO cron (dir,sh,minute,timeout) VALUES #{pli.join(',')}"
    ...vli
  )

for mod from load MOD+'.nt'
  dir = join MOD,mod
  cron_nt = join dir,'cron/cron.nt'
  if existsSync cron_nt
    console.log(cron_nt)
    nt = load cron_nt
    await load_nt mod, nt

process.exit()
