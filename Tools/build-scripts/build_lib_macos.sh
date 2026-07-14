#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="${1:-debug}"
TARGET_ARCH="${2:-universal}"

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

case "$TARGET_ARCH" in
	arm64|aarch64)
		RUST_TARGETS=(aarch64-apple-darwin)
		;;
	x86_64)
		RUST_TARGETS=(x86_64-apple-darwin)
		;;
	universal)
		RUST_TARGETS=(aarch64-apple-darwin x86_64-apple-darwin)
		;;
	*)
		echo "Usage: $0 [debug|release] [arm64|x86_64|universal]" >&2
		exit 1
		;;
esac

"$SCRIPT_DIR/check_build_env.sh" macos lib

"$SCRIPT_DIR/build_lib_sdl2.sh" macos "--$BUILD_MODE" "$TARGET_ARCH"
"$SCRIPT_DIR/build_lib_bgfx.sh" macos "--$BUILD_MODE" "$TARGET_ARCH"
"$SCRIPT_DIR/build_lib_wa.sh" macos "$BUILD_MODE" "$TARGET_ARCH"

cd "$SCRIPT_DIR/../../Source/Rust"

export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-11.3}"

for rust_target in "${RUST_TARGETS[@]}"; do
	rustup target add "$rust_target"
	cargo build "${CARGO_ARGS[@]}" --target "$rust_target"
done

if [ "$TARGET_ARCH" = "universal" ]; then
	lipo -create "target/aarch64-apple-darwin/$CARGO_PROFILE/libdora_runtime.a" "target/x86_64-apple-darwin/$CARGO_PROFILE/libdora_runtime.a" -output lib/macOS/libdora_runtime.a
else
	cp "target/${RUST_TARGETS[0]}/$CARGO_PROFILE/libdora_runtime.a" lib/macOS/libdora_runtime.a
fi
