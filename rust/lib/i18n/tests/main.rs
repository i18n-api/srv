use aok::{Result, OK};
use r::{
  fred::interfaces::{HashesInterface, RedisResult},
  R,
};
use static_init::constructor;
use tracing::info;

#[constructor(0)]
extern "C" fn init() {
  loginit::init()
}

// pub const VERIFY_MAIL: &[u8] = b"verifyMail";
i18n::gen!(auth);

#[tokio::test]
async fn test() -> Result<()> {
  let r = get_li(
    1,
    &[
      &[118, 101, 114, 105, 102, 121, 77, 97, 105, 108][..],
      &[115, 105, 103, 110, 85, 112][..],
    ],
  )
  .await?;
  for i in r {
    info!("{i}");
  }
  OK
}
