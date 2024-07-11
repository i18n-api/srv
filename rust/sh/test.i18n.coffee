#!/usr/bin/env coffee

> ./i18n
  path > join dirname

ROOT = dirname dirname import.meta.dirname

await i18n join(
  ROOT
  'mod/pub/auth/i18n'
)
process.exit()
# < default main = =>
#   cd ROOT
#   await $"ls #{ROOT}"
#   await $'pwd'
#   return
#
# if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
#   await main()
#   process.exit()
#
