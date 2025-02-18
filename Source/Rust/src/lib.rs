#[macro_use]
extern crate bitflags;

pub use dora_ssr::*;
mod bgfx_rs;
pub use bgfx_rs::*;

use clap::Parser;

#[derive(Parser)]
#[command(
	disable_help_flag = true,
	disable_version_flag = true,
	disable_help_subcommand = true,
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
