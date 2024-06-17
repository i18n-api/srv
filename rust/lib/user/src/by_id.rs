use r::fred::error::RedisError;

use crate::{pipeline, User};

pub async fn by_id_bin(uid_bin: impl AsRef<[u8]>) -> Result<User, RedisError> {
  let p = pipeline(uid_bin.as_ref()).await?;
  let (ver, lang, name): (Option<u64>, _, _) = p.all().await?;
  let lang = crate::lang::get(lang) as u32;
  Ok(User {
    ver: ver.unwrap_or(0),
    lang,
    name,
  })
}

pub async fn by_id(uid: u64) -> Result<User, RedisError> {
  let uid_bin = &intbin::u64_bin(uid)[..];
  by_id_bin(uid_bin).await
}
