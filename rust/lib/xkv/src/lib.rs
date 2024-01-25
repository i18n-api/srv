use std::{collections::BTreeMap, env, ops::Deref, path::PathBuf, str::FromStr};

use anyhow::Result;
pub use async_lazy::Lazy;
pub use fred::{
  self,
  interfaces::ClientLike,
  prelude::{ReconnectPolicy, RedisClient, RedisConfig, ServerConfig},
};
pub use paste::paste;
pub use trt::TRT;
pub struct Server {
  c: ServerConfig,
}

impl Server {
  pub fn unix_sock(path: impl Into<PathBuf>) -> Self {
    Self {
      c: ServerConfig::Unix { path: path.into() },
    }
  }
  pub fn cluster(host_port_li: Vec<(String, u16)>) -> Self {
    Self {
      c: ServerConfig::Clustered {
        hosts: host_port_li
          .into_iter()
          .map(|(host, port)| fred::types::Server::new(host, port))
          .collect(),
      },
    }
  }

  pub fn host_port(host: String, port: u16) -> Self {
    Self {
      c: ServerConfig::Centralized {
        server: fred::types::Server::new(host, port),
      },
    }
  }
}

const USER: &str = "USER";
const NODE: &str = "NODE";
const PASSWORD: &str = "PASSWORD";
const RESP: &str = "RESP";
const DB: &str = "DB";

pub struct Wrap(pub &'static Lazy<RedisClient>);

impl Deref for Wrap {
  type Target = RedisClient;
  fn deref(&self) -> &Self::Target {
    self.0.get().unwrap()
  }
}

#[macro_export]
macro_rules! conn {
  ($var:ident = $prefix:ident) => {
    $crate::paste! {
        pub static [<__ $var>]: $crate::Lazy<$crate::RedisClient> = $crate::Lazy::const_new(|| {
            Box::pin(async move { $crate::conn(stringify!($prefix)).await.unwrap() })
        });

        #[static_init::dynamic]
        pub static $var:$crate::Wrap = $crate::Wrap(&[<__ $var>]);

        #[static_init::constructor(0)]
        extern "C" fn [<init_ $prefix:lower>]() {
            $crate::TRT.block_on(async move {
                use std::future::IntoFuture;
                [<__ $var>].into_future().await;
            });
        }
    }
  };
}

fn get(u: Option<&String>) -> Option<String> {
  if let Some(u) = u {
    if u.is_empty() {
      None
    } else {
      Some(u.to_owned())
    }
  } else {
    None
  }
}

pub async fn conn(prefix: impl AsRef<str>) -> Result<RedisClient> {
  let prefix = prefix.as_ref().to_owned() + "_";

  let mut map = BTreeMap::new();

  for (key, value) in env::vars() {
    if key.starts_with(&prefix) {
      let key = &key[prefix.len()..];

      if [USER, NODE, PASSWORD, RESP, DB].contains(&key) {
        map.insert(key.to_owned(), value.trim().to_owned());
      }
    }
  }

  let host_port = map
    .get(NODE)
    .unwrap_or_else(|| unreachable!("NEED ENV {prefix}{}", NODE));

  let server = if host_port.starts_with("/") {
    Server::unix_sock(host_port)
  } else {
    let host_port = host_port
      .split(' ')
      .map(|i| i.trim())
      .filter(|i| !i.is_empty())
      .map(|i| {
        if let Some(p) = i.rfind(':') {
          let host = i[..p].to_owned();
          if i.len() > p {
            (host, i[p + 1..].parse().unwrap())
          } else {
            (host.to_owned(), 6379)
          }
        } else {
          (i.to_owned(), 6379u16)
        }
      })
      .collect::<Vec<_>>();

    if host_port.len() == 1 {
      let (host, port) = &host_port[0];
      Server::host_port(host.to_owned(), *port)
    } else {
      Server::cluster(host_port)
    }
  };

  let database = get(map.get(DB)).map(|s| u8::from_str(&s).unwrap());
  let resp = get(map.get(RESP)).map(|s| u8::from_str(&s).unwrap());
  let user = get(map.get(USER));
  let password = get(map.get(PASSWORD));

  connect(&server, user, password, database, resp).await
}

pub async fn connect(
  server: &Server,
  username: Option<String>,
  password: Option<String>,
  database: Option<u8>,
  resp: Option<u8>,
) -> Result<RedisClient> {
  let resp = match resp {
    Some(v) => {
      if v == 2 {
        fred::types::RespVersion::RESP2
      } else {
        fred::types::RespVersion::RESP3
      }
    }
    None => fred::types::RespVersion::RESP3,
  };
  let mut conf = RedisConfig {
    version: resp,
    ..Default::default()
  };
  conf.server = server.c.clone();
  conf.username = username;
  conf.password = password;
  conf.database = database;
  /*
  https://docs.rs/fred/6.2.1/fred/types/enum.ReconnectPolicy.html#method.new_constant
  */
  let policy = ReconnectPolicy::new_constant(6, 1);
  let client = RedisClient::new(conf, None, None, Some(policy));
  client.connect();
  client.wait_for_connect().await?;
  Ok(client)
}
