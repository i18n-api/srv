pub use std::net::IpAddr;

pub fn bin(ip: IpAddr) -> Box<[u8]> {
  match ip {
    IpAddr::V4(v4_addr) => v4_addr.octets().into(),
    IpAddr::V6(v6_addr) => v6_addr.octets().into(),
  }
}

#[cfg(feature = "http")]
pub use std::net::SocketAddr;

#[cfg(feature = "http")]
pub use http::HeaderMap;

#[cfg(feature = "http")]
pub const HEADER_X_FORWARDED_FOR: &str = "x-forwarded-for";

#[cfg(feature = "http")]
pub fn bin_by_header_addr(headers: &HeaderMap, addr: &SocketAddr) -> Box<[u8]> {
  bin(ip_by_header_addr(headers, addr))
}

#[cfg(feature = "http")]
pub fn ip_by_header_addr(headers: &HeaderMap, addr: &SocketAddr) -> IpAddr {
  headers
    .get(HEADER_X_FORWARDED_FOR)
    .and_then(|value| value.to_str().ok())
    .and_then(|value| value.split(',').next().map(str::trim))
    .and_then(|ip| {
      // dbg!(&ip);
      ip.parse::<IpAddr>().ok()
    })
    .unwrap_or_else(|| addr.ip())
}
