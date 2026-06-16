#!/bin/bash

set -e

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

"$SCRIPT_DIR/build_lib_sdl2.sh" macos "--$BUILD_MODE"
"$SCRIPT_DIR/build_lib_bgfx.sh" macos "--$BUILD_MODE"

cd "$SCRIPT_DIR/../../Source/Rust"

rustup target add aarch64-apple-darwin
rustup target add x86_64-apple-darwin
cargo build "${CARGO_ARGS[@]}" --target aarch64-apple-darwin
cargo build "${CARGO_ARGS[@]}" --target x86_64-apple-darwin
lipo -create "target/aarch64-apple-darwin/$CARGO_PROFILE/libdora_runtime.a" "target/x86_64-apple-darwin/$CARGO_PROFILE/libdora_runtime.a" -output lib/macOS/libdora_runtime.a
