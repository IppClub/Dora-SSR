#[macro_use]
extern crate bitflags;

pub use dora_ssr::*;
mod bgfx_rs;
pub mod dora_3d;
pub use bgfx_rs::*;

use clap::Parser;

#[cfg(test)]
#[no_mangle]
extern "C" fn str_new(_len: i32) -> i64 {
	0
}

#[cfg(test)]
#[no_mangle]
extern "C" fn str_write(_string: i64, _data: *const u8) {}

#[cfg(test)]
#[no_mangle]
extern "C" fn dora_print_error(_message: i64) {}

#[derive(Parser)]
#[command(
	disable_help_flag = true,
	disable_version_flag = true,
	disable_help_subcommand = true,
	ignore_errors = true,
	override_usage = "dora [OPTIONS]

Options:
      --asset <asset>  Set the asset path"
)]
struct Cli {
	#[arg(long)]
	asset: Option<String>,
}

#[no_mangle]
pub extern "C" fn dora_rust_init() -> i32 {
	match Cli::try_parse() {
		Ok(cli) => {
			if let Some(asset) = cli.asset {
				Content::set_asset_path(&asset);
			}
		}
		Err(e) => {
			print_error(&e.to_string());
		}
	}
	return 1;
}
