use r::{fred::interfaces::HashesInterface, R};
use trt::TRT;
use util::random_bytes;

pub static mut SK: [u8; 32] = [0; 32];

pub fn sk() -> &'static [u8] {
  unsafe { &SK[..] }
}

#[static_init::constructor(0)]
extern "C" fn init() {
  TRT.block_on(async move {
    let redis = R.0.force().await;
    let conf = &b"conf"[..];
    let key = &b"SK"[..];
    let sk: Option<Vec<u8>> = redis.hget(conf, key).await.unwrap();
    let len = unsafe { SK.len() };
    if let Some(sk) = sk {
      if sk.len() == len {
        unsafe { SK = sk.try_into().unwrap() };
        return;
      }
    }
    let sk = &random_bytes(len)[..];
    redis.hset::<(), _, _>(conf, vec![(key, sk)]).await.unwrap();
    unsafe { SK = sk.try_into().unwrap() };
  })
}
