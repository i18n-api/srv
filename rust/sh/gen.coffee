#!/usr/bin/env coffee

> ./conf > ROOT PWD
  ./i18n
  ./rm_target_if_rustc_ver_change.coffee:rmTarget
  @3-/split
  @3-/apint
  @3-/nt/load.js
  @3-/read
  @3-/write
  @ltd/j-toml:Toml
  chalk
  fs > existsSync readdirSync statSync symlinkSync
  path > join dirname basename
  toml-patch > parse patch
  zx/globals:


{greenBright} = chalk

process.chdir ROOT
MOD = 'mod'
BASE = dirname ROOT
DIR_MOD = join BASE, MOD

await rmTarget(ROOT)

readDir = (p)=>
  readdirSync(p).filter(
    (i)=>
      if not i.startsWith('.')
        return statSync(join p, i).isDirectory()
      return
  )

EXIST_MOD = new Set
MOD_LI = []
POST_LI = []
GET_LI = []
GET_PATH_LI = []
IMPORT = []

gen = (name)=>
  EXIST_MOD.add name
  dir = join DIR_MOD, name
  cargo = join dir, 'Cargo.toml'
  if not existsSync cargo
    return
  cargo = Toml.parse read cargo
  for [i, val] in Object.entries(cargo.dependencies or {})
    {path} = val
    if path
      rel = '../'
      if path.lastIndexOf(rel) == path.indexOf(rel)
        mod = join(split(name,'/')[0],basename(path))
        if not EXIST_MOD.has mod
          EXIST_MOD.add mod
          await gen mod

  lib_rs = join(dir,'src/lib.rs')
  if not existsSync lib_rs
    return

  r = await apint dir
  MOD_LI.push [name, r[0], cargo.package.name]
  IMPORT.push r[1]+'\n'
  POST_LI.push ...r[2]

  for [k,v] from Object.entries(r[3])
    if v
      GET_PATH_LI.push k+'/&'+v.join('/&')+'=>'+k
    else
      GET_LI.push k
  return

IMPORT.sort()
POST_LI.sort()
GET_LI.sort()
GET_PATH_LI.sort()

console.log ''
await Promise.all load(join(BASE,'mod.nt')).map(gen)
console.log ''

route_li = []
if POST_LI.length
  route_li.push "req!(post FnAny #{POST_LI.join(',')});"
if GET_LI.length
  route_li.push "req!(get same #{GET_LI.join(',')});"
if GET_PATH_LI.length
  route_li.push "req!(get same #{GET_PATH_LI.join(';')});"

write(
  join ROOT, 'api/src/route.rs'
  """
/// gen by init.coffee , don't edit
#[macro_export]
macro_rules! route {
  () => {
    #{route_li.join('\n    ')}
  };
}\n"""
)

dot_url = join ROOT, 'api/.url'

write(
  join dot_url, 'src/lib.rs'
  IMPORT.join('')
)

cargo_toml = [
  '''
[package]
name = "url"
version = "0.1.0"
edition = "2021"

[dependencies]
  '''
]

for [path, mod, name] from MOD_LI
  cargo_toml.push "#{mod}={path=\"../../../mod/#{path}\",package=#{JSON.stringify name}}"

write(
  join dot_url, 'Cargo.toml'
  cargo_toml.join('\n')
)

MOD_LI = MOD_LI.map((i)=>i[0])

write(
  join PWD, 'MOD.js'
  'export default '+JSON.stringify MOD_LI
)

run = (name)=>
  sh = name+'.sh'
  for mod from MOD_LI
    mod_dir = join BASE,'mod',mod
    sh_dir = join mod_dir,'sh'
    if existsSync join sh_dir,sh
      cd sh_dir
      await $"direnv allow"
      await $"direnv exec . ./#{sh}"
  return

await (await import('./lua.coffee')).default()

for mod from MOD_LI
  mod_dir = join BASE,'mod',mod
  url_i18n = join mod_dir,'i18n'
  if existsSync join url_i18n,'i18n.nt'
    await i18n url_i18n

await run 'hookEnd'

process.exit()
