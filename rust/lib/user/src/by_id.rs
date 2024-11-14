use r::fred::error::RedisError;

use crate::{_pipeline, ver_lang_name, User};

pub async fn by_id_bin(uid_bin: impl AsRef<[u8]>) -> Result<User, RedisError> {
  let bin: Vec<Vec<u8>> = _pipeline(&*r::R, uid_bin.as_ref()).await?;
  let (ver, lang, name) = ver_lang_name(bin);
  Ok(User {
    ver,
    lang: lang as _,
    name,
  })
}

pub async fn by_id(uid: u64) -> Result<User, RedisError> {
  let uid_bin = &intbin::u64_bin(uid)[..];
  by_id_bin(uid_bin).await
}
