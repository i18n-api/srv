use aok::Result;
use axum::http::request::Parts;
use t3::StatusCode;
use uid_by_token::uid_by_token;

#[derive(Copy, Clone, Debug)]
pub struct Token {
  pub id: u64,
  pub uid: u64,
}

pub async fn token(parts: &mut Parts) -> Result<Token> {
  let headers = &parts.headers;
  if let Some(t) = headers.get("t") {
    if let Some(token) = uid_by_token(t.to_str()?).await? {
      return Ok(Token {
        id: token.id,
        uid: token.uid,
      });
    }
  }
  apart::err(StatusCode::UNAUTHORIZED, "")?
}

apart::from_request_parts!(Token, token);
