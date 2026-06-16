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

"$SCRIPT_DIR/build_lib_sdl2.sh" android "--$BUILD_MODE"
"$SCRIPT_DIR/build_lib_bgfx.sh" android "--$BUILD_MODE"

cd "$SCRIPT_DIR/../../Source/Rust"

rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
cargo build "${CARGO_ARGS[@]}" --target aarch64-linux-android
cp "target/aarch64-linux-android/$CARGO_PROFILE/libdora_runtime.a" lib/Android/arm64-v8a/libdora_runtime.a
cargo build "${CARGO_ARGS[@]}" --target armv7-linux-androideabi
cp "target/armv7-linux-androideabi/$CARGO_PROFILE/libdora_runtime.a" lib/Android/armeabi-v7a/libdora_runtime.a
cargo build "${CARGO_ARGS[@]}" --target x86_64-linux-android
cp "target/x86_64-linux-android/$CARGO_PROFILE/libdora_runtime.a" lib/Android/x86_64/libdora_runtime.a
