use std::{env, fs::write, path::Path, process};

pub fn exepid() -> std::io::Result<()> {
  // 获取当前进程ID
  let pid = process::id();

  // 获取可执行文件的绝对路径
  if let Ok(exe_path) = env::current_exe() {
    let exe_folder = exe_path.parent().unwrap_or_else(|| Path::new("."));

    // 获取程序名称
    let program_name = exe_path
      .file_stem()
      .and_then(|os_str| os_str.to_str())
      .unwrap_or("");

    // 创建文件名
    let filename = exe_folder.join(format!("{}.pid", program_name));

    // 将进程ID写入文件
    write(filename, pid.to_string())?;
  }

  Ok(())
}
