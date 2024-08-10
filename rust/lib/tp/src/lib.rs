use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
  #[error("host not bind")]
  HostNoBind,
}

pub fn host_is_bind<T>(id: Option<T>) -> re::Result<T> {
  if id.is_none() {
    re::err(
      re::StatusCode::UNPROCESSABLE_ENTITY,
      Error::HostNoBind.to_string(),
    )?;
  }
  Ok(id.unwrap())
}
