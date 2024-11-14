pub struct User {
  pub ver: u64,
  pub lang: u32,
  pub name: String,
}

impl User {
  pub fn to_json(&self) -> String {
    let ver = self.ver;
    let lang = self.lang;
    let name = sonic_rs::to_string(&self.name).unwrap();

    format!("{ver},{lang},{name}")
  }
}
