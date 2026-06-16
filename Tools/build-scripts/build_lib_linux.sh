#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../Source/Rust"

build_arch() {
	case "$1" in
		aarch64|arm64)
			build_target aarch64-unknown-linux-gnu lib/Linux/aarch64
			;;
		x86_64)
			build_target x86_64-unknown-linux-gnu lib/Linux/x86_64
			;;
		*)
			echo "Unsupported Linux architecture: $1" >&2
			exit 1
			;;
	esac
}

build_target() {
	local target="$1"
	local output_dir="$2"
	local source_lib="target/$target/release/libdora_runtime.a"
	local output_lib="$output_dir/libdora_runtime.a"

	rustup target add "$target"
	cargo build --release --target "$target"
	if [ ! -f "$output_lib" ] || ! cmp -s "$source_lib" "$output_lib"; then
		cp "$source_lib" "$output_lib"
	fi
}

if [ "$#" -ne 0 ]; then
	echo "Usage: $0" >&2
	exit 1
fi

build_arch "$(uname -m)"
