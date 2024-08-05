#!/usr/bin/env coffee

> zx/globals:
  @w5/uridir
  @w5/write
  @w5/read
  path > join
  ./dir > SCHEMA
  postgres

dump = (dir, uri, {schema_name:table})=>
  pg = postgres uri
  extension = (await pg"SELECT extname FROM pg_extension WHERE extname!='plpgsql'".values()).map((i)=>i[0])

  _dump = (args, kind)=>
    sql = "#{dir}/#{kind}/#{table}.sql"
    await $"pg_dump #{uri} #{args.split(' ')} -s -n #{table} -f #{sql}"
    li = read(sql).split('\n').filter(
      (i)=>
        not i.startsWith('--')
    )
    if table == 'public'
      for i from extension
        li.unshift "CREATE EXTENSION IF NOT EXISTS #{i};"
    write(sql,li.join('\n'))
    return
  args = '--no-owner --no-acl'
  await Promise.all [
    _dump(args, 'table')
    _dump(args + ' --if-exists --clean', 'drop')
  ]
  return

< (db, q, uri)=>
  dir = join SCHEMA, db
  await Promise.all [
    $"mkdir -p #{dir}/table"
    $"mkdir -p #{dir}/drop"
  ]

  await Promise.all(
    (
      await q"SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT LIKE 'pg_%' AND schema_name != 'information_schema'"
    ).map(dump.bind(null,dir, uri))
  )

  return

