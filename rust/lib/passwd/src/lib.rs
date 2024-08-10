use blake3::Hasher;

pub const LEN: usize = 32;

pub const N: usize = 512;

pub fn hash(salt: &[u8], passwd: &[u8]) -> [u8; 16] {
  let mut hasher = Hasher::new();
  hasher.update(salt);
  hasher.update(passwd);
  let mut t = [0; N];
  for _ in 1..N {
    hasher.finalize_xof().fill(&mut t);
    hasher.update(&t);
  }
  let mut output = [0u8; 16];
  hasher.finalize_xof().fill(&mut output);
  output
}

pub fn verify(salt: &[u8], passwd: &[u8], hash: &[u8]) -> bool {
  crate::hash(salt, passwd) == hash
}
