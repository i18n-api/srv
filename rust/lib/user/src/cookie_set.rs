// use chrono::{DateTime, NaiveDateTime, Utc};
use sk::sk;
use xhash::hash64;
/// 对 BASE 求余, 为了防止数字过大,
pub const BASE: u64 = 1024;

pub fn day10() -> u64 {
  crate::day10!(sts::sec())
}

#[macro_export]
macro_rules! day10 {
  ($now:expr) => {
    ($now / (86400 * 10)) % BASE
  };
}

// fn ts2gmt(ts: u64) -> String {
//   let datetime: DateTime<Utc> = DateTime::from_utc(NaiveDateTime::from_timestamp(ts as _, 0), Utc);
//   datetime.to_rfc2822()
// }

pub fn cookie_set(host: &str, client_id: u64) -> [String; 1] {
  // let now = sts::sec();
  // let day = day10!(now);
  let day = day10();
  let t = &vb::e([day, client_id])[..];
  let token = [&hash64(&[sk(), t].concat()).to_le_bytes()[..], t].concat();
  let i = cookiestr::e(token);
  let max_age = 34560000;

  // 如果你只设置了max-age，那么在Safari中，这个cookie将会作为一个Session Cookie（当你关闭浏览器时它会被删除）

  // let expire = ts2gmt(now + max_age);
  // expires={expire};
  let age = format!(";max-age={max_age};domain={host};path=/;Partitioned;Secure;SameSite=Lax");
  [format!("I={i}{age};HttpOnly")]
}
