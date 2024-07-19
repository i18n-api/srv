pub mod hash;
pub mod mail;
use anyhow::Result;

// pub fn zip_u64(li: impl IntoIterator<Item = u64>) -> Vec<u8> {
//   let mut u64_li = vec![];
//   for i in li {
//     u64_li.push(i);
//   }
//   vbyte::compress_list(&u64_li)
// }

pub fn z85_decode_u64_li(s: impl AsRef<str>) -> Result<Vec<u64>> {
  Ok(vb::d(z85::decode(s.as_ref())?)?)
}

pub fn z85_encode_u64_li(u64_li: Vec<u64>) -> String {
  z85::encode(vb::e(u64_li))
}

pub fn random_bytes(n: usize) -> Vec<u8> {
  (0..n).map(|_| rand::random::<u8>()).collect::<Vec<u8>>()
}

pub fn u64_bin_ordered(n: u64) -> Vec<u8> {
  use ordered_varint::Variable;
  n.to_variable_vec().unwrap()
}

pub fn ordered_bin_u64(bin: impl AsRef<[u8]>) -> u64 {
  use ordered_varint::Variable;
  u64::decode_variable(bin.as_ref()).unwrap()
}
