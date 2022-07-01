use proc_macro::TokenStream;
use quote::quote;
use syn;

#[proc_macro_derive(object_macro)]
pub fn derive_object(input: TokenStream) -> TokenStream {
	let ast: syn::DeriveInput = syn::parse(input).unwrap();
	let name = ast.ident;
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
		impl #name {
			fn from(raw: i64) -> Option<#name> {
				match raw {
					0 => None,
					_ => Some(#name { raw: raw })
				}
			}
		}
	};
	gen.into()
}