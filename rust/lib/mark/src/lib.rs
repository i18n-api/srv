use markdown::{to_html_with_options, CompileOptions, Options};
pub fn htm(txt: impl AsRef<str>) -> String {
  to_html_with_options(
    txt.as_ref(),
    &Options {
      compile: CompileOptions {
        allow_dangerous_html: true,
        allow_dangerous_protocol: true,
        ..CompileOptions::default()
      },
      ..Options::default()
    },
  )
  .unwrap()
}
