pub use anyhow;
pub use paste::paste;
pub use r;
pub use sts::nano;
pub use tokio;
pub use trt;

// #[derive(Debug, Default)]
// pub struct Gid {
//   pub hset: Box<[u8]>,
//   pub cache: DashMap<Box<[u8]>, IdMax>,
// }
//
#[derive(Debug, Default)]
pub struct IdMax {
  pub id: u64,
  pub max: u64,
  pub time: u64,
  pub step: u64,
}

pub const STEP_MAX: u64 = u16::MAX as u64;
pub const ID: &[u8] = b"id";
pub const FETCH_DURATION: u64 = 600_000_000_000;

#[macro_export]
macro_rules! gid {
  ($key:ident) => {
    pub mod $key {

      use std::sync::Arc;

      use $crate::{anyhow::Result, r::R, tokio::sync::Mutex, IdMax};

      pub static ID: Mutex<IdMax> = Mutex::const_new(IdMax {
        id: 0,
        max: 0,
        time: 0,
        step: 32,
      });

      #[macro_export]
      macro_rules! next {
        ($id:ident) => {{
          use std::cmp::min;

          use $crate::{nano, r::fred::interfaces::HashesInterface};
          let now = nano();
          if $id.time > 0 {
            let diff = (now - $id.time);
            if $crate::FETCH_DURATION > diff {
              let step = $id.step;
              if step < $crate::STEP_MAX {
                $id.step = step * 2;
              }
            } else {
              if $id.step > 2 {
                $id.step /= 2
              }
            }
          }

          let step = $id.step;
          let max = r::R
            .hincrby::<u64, _, _>($crate::ID, stringify!($key), step as _)
            .await?;

          // 对大 ID 回绕
          // if max > u64::MAX - $crate::STEP_MAX {
          //   R.hset($crate::ID, (stringify!(key), 0)).await?;
          // }

          $id.max = max;
          $id.id = max - step;
          $id.time = now;
        }};
      }

      pub fn init() -> Result<()> {
        $crate::trt::TRT.block_on(async move {
          let mut id = ID.lock().await;
          R.0.force().await;
          next!(id);
          Ok(())
        })
      }
    }

    #[static_init::constructor(0)]
    extern "C" fn init() {
      $key::init().unwrap();
    }

    $crate::paste! {
        pub async fn [<gid_ $key>]()->$crate::anyhow::Result<u64>{
          let mut id =  $key::ID.lock().await;
          id.id+=1;
          let r = id.id;
          if id.id == id.max {
            next!(id);
          }
          Ok(r)
        }
    }
  };
}
