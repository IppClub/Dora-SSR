#[macro_use]
extern crate bitflags;

pub use dora_ssr::*;
mod bgfx_rs;
pub use bgfx_rs::*;

#[no_mangle]
pub extern "C" fn dora_rust_init() -> i32 {
	return 1;
}
