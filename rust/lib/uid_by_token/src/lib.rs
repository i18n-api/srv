use r::{fred::interfaces::HashesInterface, R};

#[derive(Copy, Clone, Debug)]
pub struct Token {
  pub id: u64,
  pub uid: u64,
}

pub async fn uid_by_token(token: impl AsRef<str>) -> aok::Result<Option<Token>> {
  let token = token.as_ref();
  if !token.is_empty() {
    if let Ok(token) = ub64::b64d(token) {
      if let Ok(token) = vb::d(token) {
        let sk = token[0];
        let day = token[1];
        let token_id = token[2];

        let exist: Option<Vec<u8>> = R.hget(&b"token"[..], intbin::u64_bin(token_id)).await?;

        if let Some(exist) = exist {
          let exist = vb::d(exist)?;
          if exist[0] == sk && exist[1] == day {
            return Ok(Some(Token {
              id: token_id,
              uid: exist[2],
            }));
          }
        }
      }
    }
  }
  Ok(None)
}
