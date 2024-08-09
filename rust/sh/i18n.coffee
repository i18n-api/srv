> @3-/i18n-rust:i18nRust
  fs > readdirSync

< (dir) =>
  li = readdirSync(dir).filter(
    (i)=>not i.startsWith('.')
  )
  await i18nRust(dir, li)
  return
