#!/usr/bin/env coffee

> zx/globals:
  path > dirname join
  @w5/uridir
  @w5/read
  @w5/write
  postgres
  ./table
  ./data
  ./dir > SCHEMA
  fs/promises > rename readFile opendir

{PG_BACKUP_TABLE,PG_URI,APG_URI} = process.env

# bucket='sj-backup:backup'
#
# rmOutdate = =>
#   {stdout} = await $"rclone lsjson #{bucket}"
#
#   date=new Date
#   nowym = date.getFullYear()*12 + date.getMonth()+1
#
#   for {Path} from JSON.parse stdout
#     if Path.length == 6
#       ym = parseInt Path
#       if ym
#         if (nowym - (parseInt(ym/100)*12+ym%100))>3
#           await $"rclone delete #{bucket+'/'+ym}"

dump = (uri)=>
  if not uri
    return
  uri = 'postgres://'+uri
  q = await postgres uri
  db = new URL(uri).pathname.slice(1)
  await table(db, q, uri)
  if PG_BACKUP_TABLE
    return
  for [schema_name] from await q'''select schema_name from information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog')'''.values()
    schema_name = schema_name.trim()
    if schema_name == 'pg_toast'
      continue
    await Promise.all [
      do =>

        for kind from ['table','drop']
          fp = "#{SCHEMA}/#{db}/#{kind}/#{schema_name}.sql"
            # .replaceAll('CREATE SCHEMA ','CREATE SCHEMA IF NOT EXISTS ')
          sql = read(fp)
            .replaceAll('CREATE FUNCTION ','CREATE OR REPLACE FUNCTION ')
            .replaceAll('CREATE INDEX ','CREATE INDEX IF NOT EXISTS ')
            .replace('DROP SCHEMA IF EXISTS public;','')
            .replace(
              /CREATE SCHEMA .*/g
              (t)=>
                t+'\nSET search_path TO '+schema_name+';\n'
            ).split('\n').filter(
            (i)=>
              if not i
                return false
              return not i.startsWith '--'
            ).join('\n')
          write(
            fp
            sql
          )
        return
      # $"#{ROOT}/pg/data.sh #{bucket} #{db} #{schema_name}"
    ]
  await data(db, q, uri)
  return

await Promise.all [
  APG_URI
  PG_URI
].map dump

# await $'gitsync'
process.exit()
