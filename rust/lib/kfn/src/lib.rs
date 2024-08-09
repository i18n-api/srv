#![feature(proc_macro_span)]

use convert_case::{Case, Casing};
use proc_macro::{
  TokenStream,
  TokenTree::{Group, Ident},
};

macro_rules! ident {
  ($i:ident,$key:ident,$pre:ident,$li:ident) => {{
    let span = $i.span();
    let range = span.byte_range();
    let txt = span.source_text().unwrap_or("".into());
    if range.start != $pre {
      if !$key.is_empty() {
        $li.push($key);
        $key = String::new();
      }
    }
    $key += &txt;
    $pre = range.end;
  }};
}

#[proc_macro]
pub fn kfn(input: TokenStream) -> proc_macro::TokenStream {
  let mut li = Vec::new();
  let mut key = String::new();
  let mut pre = 0;
  for i in input {
    match i {
      Group(i) => {
        ident!(i, key, pre, li);
      }
      Ident(i) => {
        ident!(i, key, pre, li);
      }
      _ => {}
    }
  }
  if !key.is_empty() {
    li.push(key);
  }
  // for i in &li {
  //   print!("{}\n", i);
  // }
  let mut r = Vec::with_capacity(li.len());
  for key in li {
    let func = key.replace(['}', '{'], "_").to_case(Case::Snake);
    r.push(format!(
      r#"pub fn {func}(bin: &[u8]) -> Box<[u8]> {{
  [b"{key}:", bin].concat().into()
}}"#
    ))
  }
  let r = r.join("\n");
  // println!("{}", r);
  r.parse().unwrap()
}
