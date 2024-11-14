#![feature(let_chains)]

mod user;
pub use user::User;
#[allow(non_snake_case)]
pub mod K;
mod by_id;
mod cookie_set;
pub mod lang;
pub use by_id::{by_id, by_id_bin};
mod pipeline;
use std::sync::atomic::{AtomicU64, Ordering::Relaxed};

use anyhow::Result;
use const_str::concat;
use cookie::Cookie;
pub use cookie_set::cookie_set;
use cookie_set::{day10, BASE};
use gid::gid;
use intbin::{bin_u64, u64_bin};
use kfn::kfn;
pub use pipeline::{_pipeline, pipeline};
use r::{
  fred::{
    interfaces::{FunctionInterface, KeysInterface, RedisResult, SortedSetsInterface},
    prelude::FromRedis,
  },
  R,
};
use sk::sk;
use sts::sec;
use ua::Ua;
use ub64::bin_u64_li;
use xhash::hash64;

kfn!(clientUid);

/// cookie 中的 day 每10天为一个周期，超过41个周期没访问就认为无效 https://chromestatus.com/feature/4887741241229312
pub const MAX_INTERVAL: u64 = 41;

pub const HASH_LEN: usize = 8; // 前8个字节是秘钥哈希

pub const UID_STATE_UNSET: u64 = 1;
pub const UID_STATE_NOUSER: u64 = 0;

const ZUMAX: &str = "zumax";
const ZSET_GT0_NOW: &str = "zsetGt0Now";

#[derive(Debug)]
pub struct ClientCookie {
  pub id: u64,
}

#[derive(Debug)]
pub enum ClientState {
  Ok(ClientCookie),
  Renew(ClientCookie),
  None,
}

#[derive(Debug, Default)]
pub struct ClientUser {
  pub id: u64,
  _uid: AtomicU64,
}

pub const INSERT_UID_CLIENT_P: &str = "INSERT INTO authUidClient (uid,client,state,cts) VALUES ";
pub const INSERT_UID_CLIENT_S: &str = " ON DUPLICATE KEY UPDATE state=VALUES(state)";
pub const INSERT_UID_CLIENT_ONE: &str =
  concat!(INSERT_UID_CLIENT_P, "(?,?,?,?)", INSERT_UID_CLIENT_S);

impl ClientUser {
  pub fn bin(&self) -> Box<[u8]> {
    u64_bin(self.id)
  }

  pub async fn uid_score<C: SortedSetsInterface + Sync>(
    &self,
    p: &C,
    uid_bin: &[u8],
    time: u64,
    sign_in: bool,
  ) -> RedisResult<()> {
    let bin = &self.bin()[..];
    let score = if sign_in { time as _ } else { -(time as f64) };
    () = p
      .zadd(client_uid(bin), None, None, false, false, (score, uid_bin))
      .await?;
    Ok(())
  }

  pub async fn sign_in<C: SortedSetsInterface + Sync>(
    &self,
    p: &C,
    uid: &[u8],
    header: &ip::HeaderMap,
    addr: &ip::SocketAddr,
    fingerprint: impl AsRef<str>,
  ) -> RedisResult<()> {
    let ua = Ua::from(fingerprint, header);
    let ip = ip::bin_by_header_addr(header, addr);
    let client_id = self.id;
    let uid_u64 = bin_u64(uid);
    let ip: Vec<_> = ip.into();

    trt::bg(async move {
      let ua_id: u64 = m::q1!(
        "SELECT authUaId(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        ua.width,
        ua.height,
        ua.pixel_ratio,
        ua.zone,
        ua.cpu,
        ua.os.0,
        ua.os.1,
        ua.os.2,
        ua.browser.0,
        ua.browser.1,
        ua.browser.2,
        ua.gpu,
        ua.lang,
        ua.arch,
      );
      m::e!(
        "SELECT authUidSignIn(?,?,?,?)",
        uid_u64,
        client_id,
        ip,
        ua_id
      );
      Ok::<_, m::Error>(())
    });

    self._uid.store(uid_u64, Relaxed);

    self.uid_score(p, uid, sec(), true).await
  }

  pub async fn set<C: FunctionInterface + Sync>(&self, p: &C, uid: &[u8]) -> RedisResult<()> {
    let bin = &self.bin()[..];
    () = p.fcall(ZSET_GT0_NOW, &[client_uid(bin)], &[uid]).await?;
    Ok(())
  }

  /// 浏览器可以同时登录多个用户, 这是找到最后一个登录的用户作为当前用户
  pub async fn last_user<R: FromRedis, C: FunctionInterface + Sync>(
    &self,
    p: &C,
  ) -> RedisResult<R> {
    let key = client_uid(&self.bin());
    p.fcall(ZUMAX, &[key], ()).await
  }

  pub fn set_uid_bin(&self, id: Option<Vec<u8>>) -> Option<u64> {
    if let Some(id) = id.map(bin_u64) {
      self._uid.store(id, Relaxed);
      Some(id)
    } else {
      self._uid.store(UID_STATE_NOUSER, Relaxed);
      None
    }
  }

  pub async fn uid(&self) -> RedisResult<Option<u64>> {
    let uid = self._uid.load(Relaxed);
    Ok(if UID_STATE_UNSET == uid {
      self.set_uid_bin(self.last_user(&*R).await?)
    } else if uid == UID_STATE_NOUSER {
      None
    } else {
      Some(uid)
    })
  }

  pub async fn exit_all(&self) -> RedisResult<()> {
    let bin = &self.bin()[..];
    let key = client_uid(bin);
    let li: Vec<Vec<u8>> = R
      .zrange(key.clone(), 0, -1, None, false, None, false)
      .await?;
    let now = sts::sec();
    if !li.is_empty() {
      let p = R.pipeline();

      let mut args = Vec::with_capacity(1 + li.len());
      args.push(INSERT_UID_CLIENT_P.to_owned());
      for uid in li {
        args.push(format!("({},{},0,{now}),", bin_u64(uid), self.id));
      }
      let mut sql = args.join("");
      sql.pop();
      sql += INSERT_UID_CLIENT_S;
      m::bg!(sql);

      () = p.del(key).await?;
      () = p.all().await?;
    }
    Ok(())
  }

  pub async fn rm<C: SortedSetsInterface + Sync>(&self, p: &C, uid: &[u8]) -> RedisResult<()> {
    let bin = &self.bin()[..];
    () = p.zrem(client_uid(bin), &[uid]).await?;
    Ok(())
  }

  pub async fn exit<C: SortedSetsInterface + Sync>(&self, p: &C, uid: &[u8]) -> RedisResult<()> {
    if self.is_login_bin(uid).await? {
      let id = self.id;
      self.uid_score(p, uid, sec(), false).await?;
      let uid_u64 = bin_u64(uid);
      m::bg!(INSERT_UID_CLIENT_ONE, uid_u64, id, 0, sts::sec());
    }
    self._uid.store(UID_STATE_UNSET, Relaxed);
    Ok(())
  }

  pub async fn is_login_bin(&self, uid_bin: &[u8]) -> RedisResult<bool> {
    let key = client_uid(&self.bin());
    let r: Option<i64> = R.zscore(key, uid_bin).await?;
    Ok(if let Some(s) = r { s > 0 } else { false })
  }
  pub async fn is_login(&self, uid: u64) -> RedisResult<bool> {
    self.is_login_bin(&u64_bin(uid)[..]).await
  }
}

fn client_by_cookie(cookie: Option<impl AsRef<str>>) -> ClientState {
  if let Some(cookie) = cookie {
    let map: gxhash::HashMap<_, _> = Cookie::split_parse(cookie.as_ref())
      .flatten()
      .map(|i| (i.name().to_owned(), i.value().to_owned()))
      .collect();
    if let Some(i) = map.get("I") {
      return client_by_cookie_map(i);
    }
  }
  ClientState::None
}

fn client_by_cookie_map(token: &str) -> ClientState {
  if let Ok(c) = cookiestr::d(token)
    && c.len() >= HASH_LEN
  {
    let client = &c[HASH_LEN..];
    if hash64([sk(), client].concat()) == u64::from_le_bytes(c[..HASH_LEN].try_into().unwrap()) {
      let li = bin_u64_li(client);
      if li.len() == 2 {
        let [pre_day10, id]: [u64; 2] = li.try_into().unwrap();

        let now = day10();
        if pre_day10 != now {
          if pre_day10 > now {
            // 当 now 超过 BASE 的时候，会从头开始，因为都是无符号类型，要避免减法出现负数
            if pre_day10 < BASE && (now + (BASE - pre_day10)) < MAX_INTERVAL {
              return ClientState::Renew(ClientCookie { id });
            }
          } else if (now - pre_day10) < MAX_INTERVAL {
            // renew
            return ClientState::Renew(ClientCookie { id });
          }
        } else {
          return ClientState::Ok(ClientCookie { id });
        }
      }
    }
  }
  ClientState::None
}

gid!(client);

pub async fn client_by_token(token: impl AsRef<str>) -> Result<ClientUser> {
  let _token = token.as_ref();
  Ok(ClientUser {
    ..Default::default()
  })
}

pub async fn client_user_cookie(cookie: Option<impl AsRef<str>>) -> Result<(ClientUser, bool)> {
  let (client_id, _uid) = match client_by_cookie(cookie) {
    ClientState::Ok(c) => {
      return Ok((
        ClientUser {
          id: c.id,
          _uid: UID_STATE_UNSET.into(),
        },
        false,
      ));
    }
    ClientState::Renew(c) => (c.id, UID_STATE_UNSET),
    ClientState::None => (gid_client().await?, UID_STATE_NOUSER),
  };

  Ok((
    ClientUser {
      id: client_id,
      _uid: _uid.into(),
    },
    true,
  ))
}

pub fn ver_lang_name(bin: Vec<Vec<u8>>) -> (u64, u32, String) {
  let ver = &bin[0];
  let ver = if ver.is_empty() {
    0
  } else {
    String::from_utf8_lossy(ver).parse().unwrap_or(0)
  };
  let lang = lang::get(&bin[1]);
  let name = String::from_utf8_lossy(&bin[2]);
  (ver, lang as _, name.into())
}
