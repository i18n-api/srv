#!/usr/bin/env coffee

> @3-/apint > scan
  ./conf.coffee > ROOT
  path > join dirname

await scan join dirname(ROOT),'mod'
process.exit()
