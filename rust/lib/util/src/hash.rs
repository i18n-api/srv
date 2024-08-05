pub fn token(bin: &[u8]) -> String {
  let token = bs58::encode(xhash::hash64(bin).to_be_bytes()).into_string();
  token[0..7].into()
}
