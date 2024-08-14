#!/usr/bin/env coffee

> zx/globals:
  @w5/uridir
  path > basename join
  ./dir > BAK ROOT


< default main = (uri,name)=>
  if not ( uri and uri.endsWith '-dev' )
    console.log "数据库名称不包含 -dev 不执行，小心误操作\n#{uri}"
    return

  ol = name + '-ol'
  cd "#{BAK}/schema/#{ol}/drop"

  {
    stdout:sql_li
  } = await $"ls *.sql"
  pguri = 'postgres://'+uri
  psql = "psql #{pguri}"

  sh = (cmd)=>
    $"sh -c #{cmd}"

  await sh "#{psql} < #{ROOT}/extension.sql"

  schema_li = []
  for sql from sql_li.trim().split '\n'
    schema = basename(sql).slice(0,-4)
    schema_li.push schema
    if schema != 'public'
      await sh """#{psql} -c "DROP SCHEMA #{schema} CASCADE" || true"""
    await sh "#{psql} < #{sql} >/dev/null"
  await $"#{ROOT}/_load.sh #{ol} #{pguri} #{schema_li.join(' ')}"
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  for i in 'pg apg'.split(' ')
    uri = process.env[i.toUpperCase()+'_URI']
    if uri
      await main(uri,i)
  process.exit()

