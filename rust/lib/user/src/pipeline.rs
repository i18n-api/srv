use r::{
  fred::{
    clients::{Pipeline, RedisClient},
    error::RedisError,
    interfaces::HashesInterface,
  },
  R,
};

use crate::K;

pub async fn pipeline(uid_bin: &[u8]) -> Result<Pipeline<RedisClient>, RedisError> {
  let p = R.pipeline();
  p.hget(K::VER, uid_bin).await?;
  p.hget(K::LANG, uid_bin).await?;
  p.hget(K::NAME, uid_bin).await?;
  Ok(p)
}
