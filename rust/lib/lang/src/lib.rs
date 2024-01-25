mod code_id;

pub use code_id::LANG;
pub use const_str;
pub use http::HeaderMap;
pub use intbin::u8_bin;

// pub const NOSPACE: phf::Set<&str> = phf::phf_set! {"zh", "zh-TW", "ja", "km", "th", "lo"};

pub const NOSPACE: [u8; 6] = [1, 5, 40, 61, 106, 130];

pub fn space(lang: u8) -> &'static str {
  if NOSPACE.contains(&lang) {
    ""
  } else {
    " "
  }
}

pub fn lang_bin(lang: &str) -> Box<[u8]> {
  u8_bin(lang_id(lang))
}

pub fn lang_id(lang: &str) -> u8 {
  if let Some(p) = LANG.get_index(lang) {
    return p as _;
  }
  0
}

#[macro_export]
macro_rules! gen {
  ($key:ident) => {
    pub const HSET_PREFIX: &[u8] = $crate::const_str::concat!(stringify!($key), "I18n:").as_bytes();

    pub async fn get_li<'a, const N: usize>(
      lang: u8,
      li: &'a [&[u8]; N],
    ) -> RedisResult<Vec<String>> {
      let hset = &[HSET_PREFIX, &$crate::u8_bin(lang)].concat()[..];
      R.hmget(hset, li).await
    }

    pub async fn get<'a, const N: usize>(
      header: &$crate::HeaderMap,
      key: &'a [u8],
    ) -> RedisResult<Vec<String>> {
      let lang = $crate::header(header);
      let hset = &[HSET_PREFIX, &$crate::u8_bin(lang)].concat()[..];
      R.hget(hset, key).await
    }

    pub async fn throw_li<'a, const N: usize>(
      header: &$crate::HeaderMap,
      key: impl AsRef<str>,
      li: &'a [&[u8]; N],
    ) -> anyhow::Result<()> {
      let lang = $crate::header(header);
      let li = get_li(lang, li).await?;
      let space = $crate::space(lang);
      Ok(re::form::Error::throw(key.as_ref(), li.join(space))?)
    }

    pub async fn throw(
      header: &$crate::HeaderMap,
      key: impl AsRef<str>,
      val: &[u8],
    ) -> anyhow::Result<()> {
      let lang = $crate::header(header);
      let hset = &[HSET_PREFIX, &$crate::u8_bin(lang)].concat()[..];
      let val: String = R.hget(hset, val).await?;
      Ok(re::form::Error::throw(key.as_ref(), val)?)
    }
  };
}

pub fn header_bin(m: &HeaderMap) -> Box<[u8]> {
  u8_bin(header(m))
}

pub fn header(m: &HeaderMap) -> u8 {
  if let Some(i) = m.get("accept-language") {
    if let Ok(i) = i.to_str() {
      return lang_id(i);
    }
  }
  0
}
