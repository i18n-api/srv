use fred::{
  error::RedisError,
  interfaces::KeysInterface,
  prelude::{FromRedis, RedisResult},
};
use xbin::concat;

use crate::K;

pub async fn _pipeline<R: FromRedis>(
  pipeline: &impl KeysInterface,
  uid_bin: &[u8],
) -> RedisResult<R> {
  pipeline
    .mget::<R, _>(&[
      concat!(K::VER, uid_bin),
      concat!(K::LANG, uid_bin),
      concat!(K::NAME, uid_bin),
    ])
    .await
}

pub async fn pipeline(pipeline: &impl KeysInterface, uid_bin: &[u8]) -> Result<(), RedisError> {
  _pipeline(pipeline, uid_bin).await
}
