use gid::gid;

gid!(client);

#[tokio::test]
async fn test() -> anyhow::Result<()> {
  for _ in 0..9 {
    let a = gid_client().await?;
    println!("{}", a)
  }
  Ok(())
}
