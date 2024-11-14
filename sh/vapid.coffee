#!/usr/bin/env coffee

> web-push:webpush


n = 0
loop
  {
    publicKey
    privateKey
  } = webpush.generateVAPIDKeys()

  try
    s = Buffer.from(atob(publicKey),'binary')
    buf = Buffer.from(publicKey,'base64')
    # consoel.log s.length, buf.length
    bytes = Uint8Array.from(atob(publicKey), (c) => c.charCodeAt(0))
    if buf.compare(s) == 0
      console.log(publicKey)
      console.log(privateKey)
      console.log(bytes)
      break
    # else
    #   console.log s
    #   console.log buf
    #   console.log ''
  catch err
    ++n
    continue
# ROOT = import.meta.dirname
#
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
