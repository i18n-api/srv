pub fn get(lang: &[u8]) -> u8 {
  if lang.is_empty() { 0 } else { lang[0] }
}
