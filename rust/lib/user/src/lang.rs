pub fn get(lang: Option<Vec<u8>>) -> u8 {
  if let Some(lang) = lang {
    return if lang.is_empty() { 0 } else { lang[0] };
  }
  0
}
