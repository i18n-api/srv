use axum::http::request::Parts;
use t3::StatusCode;
use uid_by_token::uid_by_token;

use crate::client;

#[derive(Clone, Debug, Copy)]
pub struct Uid(pub u64);

pub async fn uid(parts: &mut Parts) -> aok::Result<Uid> {
  let headers = &parts.headers;
  if let Some(t) = headers.get("t") {
    if let Some(token) = uid_by_token(t.to_str()?).await? {
      return Ok(Uid(token.uid));
    }
  } else {
    let client = client(parts).await?;
    if let Some(id) = client.uid().await? {
      return Ok(Uid(id));
    }
  }
  apart::err(StatusCode::UNAUTHORIZED, "")?
}

apart::from_request_parts!(Uid, uid);
