#!/usr/bin/env coffee

> ./dir > DATA ROOT
  path > join basename dirname

dump = (fp, uri, schema)=>
  await $"pg_dump #{uri} --data-only -n #{schema} -Fc -Z0 | zstd -T0 -15 > #{fp}"
  return

RCLONE = join dirname(ROOT),'rclone_'

dtStr = (date) =>
  tzo = -date.getTimezoneOffset()
  dif = if tzo >= 0 then '+' else '-'

  pad = (num) ->
    norm = Math.floor(Math.abs(num))
    (if norm < 10 then '0' else '') + norm

  date.getFullYear() + '-' + pad(date.getMonth() + 1) + '-' + pad(date.getDate()) + '_' + pad(date.getHours()) + '.' + pad(date.getMinutes()) + '.' + pad(date.getSeconds())

NOW = dtStr new Date

< (db, q, uri)=>
  dir = join DATA,db
  await $"mkdir -p #{dir}"
  bname = basename dir
  pg_dir = "pg.#{bname}"
  rclone = not bname.includes '-dev'
  for {schema_name:schema} from await q"SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT LIKE 'pg_%' AND schema_name != 'information_schema'"
    fp = "#{dir}/#{schema}.zstd"
    await dump(fp,uri,schema)
    if rclone
      await $"#{RCLONE}cp.sh #{fp} #{pg_dir}/#{NOW}"
  if rclone
    await $"#{RCLONE}rm.sh #{pg_dir}"
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()

