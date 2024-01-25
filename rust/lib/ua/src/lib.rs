use std::cmp::min;

use base64::prelude::{Engine as _, BASE64_STANDARD_NO_PAD};
use http::header::USER_AGENT;
use woothee::parser::Parser;

#[derive(Debug, Clone)]
pub struct Ua {
  pub width: u16,
  pub height: u16,
  pub lang: String,
  pub arch: String,
  pub gpu: String,
  pub pixel_ratio: u8,
  pub zone: i16,
  pub cpu: u16,
  pub os: (String, u16, u16),
  pub browser: (String, u16, u16),
}

const U16_MAX: u64 = u16::MAX as _;
const U8_MAX: u64 = u8::MAX as _;

fn as_u8(i: u64) -> u8 {
  min(i, U8_MAX) as _
}

fn as_u16(i: u64) -> u16 {
  min(i, U16_MAX) as _
}

fn parse_u16(i: &str) -> u16 {
  if let Ok(i) = i.parse() {
    i
  } else {
    0
  }
}

impl Ua {
  pub fn from(fingerprint: impl AsRef<str>, header: &http::HeaderMap) -> Self {
    let mut lang = "";
    let mut width: u16 = 0;
    let mut height: u16 = 0;
    let mut pixel_ratio: u8 = 0;
    let mut zone: i16 = 0;
    let mut cpu: u16 = 0;

    let mut os = "";
    let mut os_ver_major: u16 = 0;
    let mut os_ver_minor: u16 = 0;

    let mut browser = "";
    let mut browser_ver_major = 0;
    let mut browser_ver_minor = 0;

    let mut gpu = Default::default();
    let mut arch = "";

    let fingerprint = fingerprint.as_ref().split('<');
    for (pos, i) in fingerprint.enumerate() {
      match pos {
        0 => {
          if let Ok(i) = BASE64_STANDARD_NO_PAD.decode(i) {
            if let Ok(li) = vb::d(i) {
              width = as_u16(li[0]);
              height = as_u16(li[1]);
              pixel_ratio = as_u8(li[2]);
              zone = (as_u16(li[3]) as i16) - 720;
              cpu = as_u16(li[4]);
              if li.len() >= 7 {
                os_ver_major = as_u16(li[5]);
                os_ver_minor = as_u16(li[6]);
              }
            }
          }
        }
        1 => {
          lang = i;
        }
        _ => match i.chars().nth(0) {
          Some('0') => {
            arch = &i[1..];
          }
          Some('1') => {
            let g = &i[1..].replace(": ", ":").replace(", ", ",").to_owned();
            let mut g = g.as_str();
            if g.starts_with("ANGLE (") {
              g = &g[7..g.len() - 1];
            }
            if g.starts_with("Apple,") {
              g = &g[6..];
            }
            if g.starts_with("ANGLE Metal Renderer:") {
              g = &g[21..];
            }
            gpu = g.replace(",Unspecified Version", "").to_owned();
          }
          _ => {}
        },
      }
    }
    if let Some(user_agent) = header.get(USER_AGENT) {
      if let Ok(user_agent) = user_agent.to_str() {
        if let Some(user_agent) = Parser::new().parse(user_agent) {
          browser = user_agent.name;
          os = user_agent.os;
          macro_rules! ver {
            ($major:ident,$minor:ident,$ver:ident) => {{
              for (pos, i) in user_agent.$ver.split(".").enumerate() {
                match pos {
                  0 => $major = parse_u16(i),
                  1 => $minor = parse_u16(i),
                  _ => break,
                }
              }
            }};
          }
          if os_ver_major == 0 && os_ver_minor == 0 {
            ver!(os_ver_major, os_ver_minor, os_version);
          }
          ver!(browser_ver_major, browser_ver_minor, version);
          // name: "Chrome",
          // category: "pc",
          // os: "Mac OSX",
          // os_version: "10.15.7",
          // browser_type: "browser",
          // version: "119.0.0.0",
          // vendor: "Google",
        }
      }
    }
    Self {
      lang: lang.into(),
      arch: arch.into(),
      gpu,
      width,
      height,
      pixel_ratio,
      zone,
      cpu,
      os: (os.into(), os_ver_major, os_ver_minor),
      browser: (browser.into(), browser_ver_major, browser_ver_minor),
    }
  }
}
