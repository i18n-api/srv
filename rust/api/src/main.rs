#![feature(async_closure)]
#![feature(const_trait_impl)]
#![feature(exact_size_is_empty)]
#![feature(impl_trait_in_assoc_type)]
#![feature(type_alias_impl_trait)]
#![feature(let_chains)]
#![allow(non_snake_case)]

mod route;
use axum::{middleware, routing, Router};
use exepid::exepid;
use set_header::set_header;

genv::def!(PORT:u16 | 8850);

#[tokio::main(flavor = "multi_thread")]
async fn main() -> anyhow::Result<()> {
  exepid()?;
  // let prepare =
  //   TRT.block_on(async move { xg::PG.force().await.prepare(" INSERT INTO fav.user (uid,cid,rid,ts,aid) VALUES ($1) ON CONFLICT (uid, cid, rid, ts) DO NOTHING RETURNING id").await.unwrap() });

  loginit::init();

  let mut router = Router::new();

  macro_rules! req {
    // (=> $func:ident) => {
    //     post!("", $func)
    // };
    ($method:ident $wrap:ident  $($url:ident),+) => {
        req!($method $wrap $($url=>$url);+)
    };
    ($method:ident $wrap:ident $($url:stmt => $func:ident);+) => {
        $(
          req!(
              $method
              $wrap
              const_str::replace!(
                  const_str::replace!(
                      const_str::unwrap!(const_str::strip_suffix!(stringify!($url), ";")),
                      " ",
                      ""
                  ),
                  "&",
                  ":"
              ),
              $func
          );
        )+
    };
    ($method:ident $wrap:ident $url:expr, $func:ident) => {
      router = router.route(
        const_str::concat!('/', $url),
        routing::$method(re::$wrap(url::$func::$method)),
      )
    };
  }

  route!();

  t3::srv(router.layer(middleware::from_fn(set_header)), PORT()).await;
  Ok(())
}
