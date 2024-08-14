#!/usr/bin/env coffee

> zx/globals:
  @3-/write
  @3-/read
  path > join
  fs > existsSync rmSync

+ stdout

< default main = (dir)=>
  if not stdout
    {stdout} = (await $"rustc -V")

  v = join dir,'.rustcV'

  rmTarget = =>
    write(
      v
      stdout
    )
    target = join dir, 'target'
    if existsSync target
      rmSync(
        target
        {
          recursive: true
          force: true
        }
      )
    return
  if not existsSync v
    rmTarget()
    return

  if stdout != read v
    rmTarget()
  return

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main('.')
  process.exit()
