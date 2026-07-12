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

"$SCRIPT_DIR/check_build_env.sh" android lib

"$SCRIPT_DIR/build_lib_sdl2.sh" android "--$BUILD_MODE"
"$SCRIPT_DIR/build_lib_bgfx.sh" android "--$BUILD_MODE"
"$SCRIPT_DIR/build_lib_wa.sh" android "$BUILD_MODE"

cd "$SCRIPT_DIR/../../Source/Rust"

rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android

NDK_PATH="${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-${NDK_ROOT:-}}}"
if [ -z "$NDK_PATH" ]; then
	echo "Android NDK path is required to compile the Jolt C++ runtime." >&2
	exit 1
fi
TOOLCHAIN_DIRS=("$NDK_PATH/toolchains/llvm/prebuilt/"*)
TOOLCHAIN_BIN="${TOOLCHAIN_DIRS[0]}/bin"
ANDROID_API="${ANDROID_API:-28}"

build_rust_target() {
	local target="$1"
	local env_target="$2"
	local compiler_prefix="$3"
	env \
		"CC_$env_target=$TOOLCHAIN_BIN/${compiler_prefix}${ANDROID_API}-clang" \
		"CXX_$env_target=$TOOLCHAIN_BIN/${compiler_prefix}${ANDROID_API}-clang++" \
		"AR_$env_target=$TOOLCHAIN_BIN/llvm-ar" \
		cargo build "${CARGO_ARGS[@]}" --target "$target"
}

build_rust_target aarch64-linux-android aarch64_linux_android aarch64-linux-android
cp "target/aarch64-linux-android/$CARGO_PROFILE/libdora_runtime.a" lib/Android/arm64-v8a/libdora_runtime.a
build_rust_target armv7-linux-androideabi armv7_linux_androideabi armv7a-linux-androideabi
cp "target/armv7-linux-androideabi/$CARGO_PROFILE/libdora_runtime.a" lib/Android/armeabi-v7a/libdora_runtime.a
build_rust_target x86_64-linux-android x86_64_linux_android x86_64-linux-android
cp "target/x86_64-linux-android/$CARGO_PROFILE/libdora_runtime.a" lib/Android/x86_64/libdora_runtime.a
