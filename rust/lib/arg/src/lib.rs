use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, FnArg, Ident, ItemFn, PatType, Token, Type};

#[proc_macro_attribute]
pub fn captcha(_attr: TokenStream, item: TokenStream) -> TokenStream {
  let mut input_fn = parse_macro_input!(item as ItemFn);

  let arg_ident = Ident::new("_", input_fn.sig.ident.span());
  let arg_type = syn::parse_str::<Type>("captcha::Captcha").unwrap();
  let new_arg = FnArg::Typed(PatType {
    attrs: vec![],
    pat: Box::new(syn::Pat::Ident(syn::PatIdent {
      attrs: vec![],
      by_ref: None,
      mutability: None,
      ident: arg_ident,
      subpat: None,
    })),
    colon_token: Token![:](input_fn.sig.ident.span()),
    ty: Box::new(arg_type),
  });

  input_fn.sig.inputs.insert(0, new_arg);

  TokenStream::from(quote!(#input_fn))
}
