use aok::{Result, OK};
use uid_by_token::uid_by_token;

#[tokio::test]
async fn main() -> Result<()> {
  let token_li = ["O2EFTo6WvdWhoICt4gQBkfXPswY", "O2EFTo6WvdWhoICt4gQBkfXPsw1"];
  for token in token_li {
    let uid = uid_by_token(token).await?;
    dbg!((token, uid));
  }
  OK
}
