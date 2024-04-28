#![feature(async_closure)]
use std::time::{Duration, Instant};

use anyhow::Result;
use chrono::Local;
use duct::cmd;
use tokio::time::sleep;

genv::s!(WARN_MAIL);

// #[static_init::dynamic]
// pub static HOME: String = dirs::home_dir().unwrap().display().to_string();

pub async fn logerr(cron_id: u32, dir: String, sh: String, code: i32, msg: &[u8]) -> Result<()> {
  let txt = String::from_utf8_lossy(msg);
  let now = sts::sec();
  println!("cron_id {cron_id} exit {code}\n{txt}\n");
  m::e!(
    format!("INSERT INTO cronErr(cron_id,code,ts,msg)VALUES({cron_id},{code},{now},?)"),
    msg
  );

  xsmtp::send_bg(
    "mycron",
    &**WARN_MAIL,
    format!("{dir} {sh} EXIT {code}"),
    txt,
    "",
  );
  Ok(())
}

pub async fn run(
  root: String,
  cron_id: u32,
  dir: String,
  sh: String,
  timeout: u64,
  preok: u64,
) -> Result<()> {
  let cmd = format!(
    "cd \"{root}/{dir}/cron\"&&exec direnv exec . timeout {timeout}m ./{sh}",
    // &*HOME
  );
  let start_time = Instant::now();
  print!("{dir} ❯ {sh} ");

  let r = cmd!("bash", "-c", cmd)
    .unchecked()
    .stderr_to_stdout()
    .stdout_capture()
    .run();
  let elapsed = start_time.elapsed();
  println!("{}s", elapsed.as_millis() as f32 / 1000.0);

  match r {
    Ok(out) => {
      let code = if let Some(code) = out.status.code() {
        code
      } else {
        -1
      };
      if code == 0 {
        let now = sts::min();
        let begin = if preok == 0 { now } else { preok };
        m::e!(format!(
          "UPDATE cron SET next={begin}+minute,preok={now} WHERE id={cron_id}"
        ))
      } else {
        logerr(cron_id, dir, sh, code, &out.stdout).await?;
      }
    }
    Err(err) => {
      logerr(cron_id, dir, sh, -2, err.to_string().as_bytes()).await?;
    }
  }

  Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
  if let Some(root) = std::env::args().nth(1) {
    loop {
      println!("{}", Local::now().format("%Y-%m-%d %H:%M:%S"));
      let start_time = Instant::now();
      let li: Vec<(u32, String, String, u64, u64)> = m::q!("CALL cronLi()");
      for (id, dir, sh, timeout, preok) in li {
        xerr::log!(tokio::spawn(run(root.clone(), id, dir, sh, timeout, preok)).await);
      }

      let elapsed = start_time.elapsed();
      let minute = Duration::from_secs(60);
      if elapsed < minute {
        sleep(minute - elapsed).await;
      }
    }
  } else {
    eprintln!("miss args dir");
    std::process::exit(1);
  }
}
