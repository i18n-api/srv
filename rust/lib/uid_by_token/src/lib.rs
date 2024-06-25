use intbin::{bin_u64, u64_bin};
use r::{fred::interfaces::HashesInterface, R};
use sha2::{Digest, Sha256};

genv::s!(TOKEN_SK);

#[derive(Copy, Clone, Debug)]
pub struct Token {
  pub id: u64,
  pub uid: u64,
}

pub const TOKEN: &[u8] = b"token";
pub const HASH_LEN: usize = 10;

pub async fn uid_by_token(token: impl AsRef<str>) -> aok::Result<Option<Token>> {
  let token = token.as_ref();
  if !token.is_empty() {
    if let Ok(token) = ub64::b64d(token) {
      if token.len() > HASH_LEN {
        let bin = &token[HASH_LEN..];
        let mut hasher = Sha256::new();
        hasher.update(bin);
        hasher.update(TOKEN_SK.as_bytes());
        let hash = &hasher.finalize()[..HASH_LEN];
        if &token[0..HASH_LEN] == hash {
          if let Ok(id_li) = vb::d(bin) {
            if id_li.len() == 3 {
              let token_id = id_li[1];
              let exist: Option<Vec<u8>> = R.hget(TOKEN, u64_bin(token_id)).await?;

              if let Some(exist) = exist {
                let ts = id_li[2];
                if bin_u64(&exist) == ts {
                  return Ok(Some(Token {
                    uid: id_li[0],
                    id: token_id,
                  }));
                }
              }
            }
          }
        }
      }
    }
  }
  Ok(None)
}
