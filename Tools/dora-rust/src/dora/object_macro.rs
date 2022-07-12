use proc_macro::TokenStream;
use quote::quote;
use syn::{self, Expr};

#[proc_macro_derive(object_macro)]
pub fn derive_object(input: TokenStream) -> TokenStream {
	let ast: syn::DeriveInput = syn::parse(input).unwrap();
	let name = ast.ident;
	let expr = syn::parse_str::<Expr>(format!("{}_type()", name.to_string().to_lowercase()).as_str()).unwrap();
	let gen = quote! {
		impl Object for #name {
			fn raw(&self) -> i64 { self.raw }
			fn obj(&self) -> &dyn Object { self }
			fn as_any(&self) -> &dyn Any { self }
			fn as_any_mut(&mut self) -> &mut dyn Any { self }
		}
		impl Drop for #name {
			fn drop(&mut self) { unsafe { object_release(self.raw); } }
		}
		impl Clone for #name {
			fn clone(&self) -> #name {
				unsafe { object_retain(self.raw); }
				#name { raw: self.raw }
			}
		}
		impl #name {
			pub fn from(raw: i64) -> Option<#name> {
				match raw {
					0 => None,
					_ => Some(#name { raw: raw })
				}
			}
			pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn Object>>) {
				(unsafe { #expr }, |raw: i64| -> Option<Box<dyn Object>> {
					match raw {
						0 => None,
						_ => Some(Box::new(#name { raw: raw }))
					}
				})
			}
		}
	};
	gen.into()
}