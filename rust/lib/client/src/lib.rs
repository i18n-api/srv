#![feature(async_closure)]

use std::ops::Deref;

use axum::{
  http::{
    header::{COOKIE, SET_COOKIE}, // HOST
    request::Parts,
    StatusCode,
  },
  Extension, RequestPartsExt,
};
use set_header::Header;
use t3::host::Error;
pub use user;
use user::{client_user_cookie, cookie_set, ClientUser};
use xtld::url_tld;

mod token;
mod uid;
pub use token::Token;
pub use uid::Uid;

pub struct Client(pub ClientUser);

impl Deref for Client {
  type Target = ClientUser;
  fn deref(&self) -> &<Self as Deref>::Target {
    &self.0
  }
}

#[macro_export]
macro_rules! unauthorized {
  () => {
    re::err(StatusCode::UNAUTHORIZED, "".to_owned())
  };
}

impl Client {
  pub async fn uid_logined(&self, uid: u64) -> Result<(), re::Err> {
    if uid > user::UID_STATE_UNSET && self.is_login(uid).await? {
      return Ok(());
    }
    unauthorized!()
  }

  pub async fn logined(&self) -> Result<u64, re::Err> {
    if let Some(id) = self.uid().await? {
      return Ok(id);
    }
    unauthorized!()
  }
}

pub async fn client(parts: &mut Parts) -> aok::Result<Client> {
  let headers = &parts.headers;
  let host = t3::origin_tld(headers);
  if let Ok(host) = host {
    let cookie = if let Some(Ok(c)) = headers.get(COOKIE).map(|i| i.to_str()) {
      Some(c)
    } else {
      None
    };

    let (client_user, set_cookie) = client_user_cookie(cookie).await?;
    if set_cookie {
      let host = url_tld(host);
      let cookie_li = cookie_set(&host, client_user.id);

      let Extension(map) = parts.extract::<Extension<Header>>().await?;
      for i in cookie_li.into_iter() {
        map.push(SET_COOKIE, i);
      }
    }
    return Ok(Client(client_user));
  }
  Err(Error::HeaderMissHost)?
}

apart::from_request_parts!(Client, client);
