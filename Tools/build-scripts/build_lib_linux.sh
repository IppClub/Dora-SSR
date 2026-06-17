#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="${1:-debug}"

case "$BUILD_MODE" in
	debug|--debug|-d)
		BUILD_MODE="debug"
		CARGO_PROFILE="debug"
		CARGO_ARGS=()
		;;
	release|--release|-r)
		BUILD_MODE="release"
		CARGO_PROFILE="release"
		CARGO_ARGS=(--release)
		;;
	*)
		echo "Usage: $0 [debug|release]" >&2
		exit 1
		;;
esac

"$SCRIPT_DIR/check_build_env.sh" linux lib

"$SCRIPT_DIR/build_lib_sdl2.sh" linux "--$BUILD_MODE"
"$SCRIPT_DIR/build_lib_bgfx.sh" linux "--$BUILD_MODE"
"$SCRIPT_DIR/build_lib_wa.sh" linux "$BUILD_MODE"

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
	local source_lib="target/$target/$CARGO_PROFILE/libdora_runtime.a"
	local output_lib="$output_dir/libdora_runtime.a"

	rustup target add "$target"
	cargo build "${CARGO_ARGS[@]}" --target "$target"
	if [ ! -f "$output_lib" ] || ! cmp -s "$source_lib" "$output_lib"; then
		cp "$source_lib" "$output_lib"
	fi
}

if [ "$#" -gt 1 ]; then
	echo "Usage: $0 [debug|release]" >&2
	exit 1
fi

build_arch "$(uname -m)"
