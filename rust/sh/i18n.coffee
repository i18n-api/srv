> @3-/i18n-rust:i18nRust
  fs > readdirSync

< (dir) =>
  li = readdirSync(dir).filter(
    (i)=>not i.startsWith('.')
  )

  i18nRust(dir, li)
  return
