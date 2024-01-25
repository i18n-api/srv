#!/usr/bin/env coffee

> @3-/read
  ./conf > PWD ROOT
  path > join dirname basename
  ./MOD.js
  fs > existsSync
  @3-/walk
  @3-/write
  @3-/snake > SNAKE
  @3-/camel
  @3-/redis/R.js

flagsDef = (name, flags)=>
  if flags.length
    def = \
    """
{function_name='#{name}',callback=#{name},flags={'#{flags.join('\',\'')}'}}
    """
  else
    def = "('#{name}',#{name})"
  return def

load = (mod, fp)=>
  li = []
  name_li = []
  for i from read(fp).split('\n')
    i = i.trimEnd()

    trimStart = i.trimStart()
    if trimStart.startsWith('--')
      i = trimStart.slice(3)
      if i.startsWith('flags ')
        flags = flags.concat i.slice(6).trim().split(' ')
      continue

    if i.startsWith('function ')
      flags = []
      name = i.slice(9,i.indexOf('(',10)).trim()
      i = 'local '+i+'\n  redis.setresp(3)'
    else if ~i.indexOf('function(')
      name = undefined

    li.push i

    if i == 'end' and name
      def = flagsDef(name,flags)
      name_li.push name
      li.push "redis.register_function#{def}"


  if name_li.length
    lua_rs = name_li.map(
      (i)=>
        "pub const #{SNAKE i}: &str = \"#{i}\";\n"
    ).join('')
  return [
    li.join('\n').trimEnd()
    lua_rs
  ]

export default main = =>
  name = 'redis.lua'
  code = load('',join ROOT, name)[0]
  console.log "-- #{name}\n\n"+code

  code = '#!lua name=I18N\n'+code

  base = dirname ROOT
  for mod from MOD
    rustdir = join base,'mod',mod
    lua = join rustdir, 'redis.lua'
    if existsSync lua
      [c,rs] = load(mod, lua)
      code += c
      console.log "\n-- #{mod}\n"+c
      if rs
        lua_rs = join rustdir,'src/LUA.rs'
        write(
          lua_rs
          rs
        )

  await R.function('LOAD','REPLACE', code)
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()
