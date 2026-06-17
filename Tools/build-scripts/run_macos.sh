#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../.."
MACHINE_ARCH="$(uname -m)"

case "$MACHINE_ARCH" in
	arm64|aarch64)
		RUST_TARGET="aarch64-apple-darwin"
		XCODE_ARCH="arm64"
		;;
	x86_64)
		RUST_TARGET="x86_64-apple-darwin"
		XCODE_ARCH="x86_64"
		;;
	*)
		echo "Unsupported macOS architecture: $MACHINE_ARCH" >&2
		exit 1
		;;
esac

stop_running_dora() {
	if pgrep -x Dora >/dev/null; then
		pkill -x Dora
		while pgrep -x Dora >/dev/null; do
			sleep 0.2
		done
	fi
}

ensure_dependencies() {
	local missing=0
	local dependency
	local required_dependencies=(
		"$ROOT_DIR/Source/3rdParty/SDL2/Lib/macOS/libSDL2.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libbgfx.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libbimg.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libbimg_decode.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libbx.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libfcpp.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libshaderc-lib.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libspirv-cross.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libspirv-opt.a"
		"$ROOT_DIR/Source/3rdParty/bgfx/build/macosx/universal/libglslang.a"
		"$ROOT_DIR/Source/3rdParty/Wa/Lib/macOS/libwa.a"
	)

	for dependency in "${required_dependencies[@]}"; do
		if [ ! -f "$dependency" ]; then
			echo "Missing dependency: $dependency"
			missing=1
		fi
	done

	if [ "$missing" -ne 0 ]; then
		echo "Building macOS native dependencies..."
		"$SCRIPT_DIR/build_lib_macos.sh" debug
	fi
}

"$SCRIPT_DIR/check_build_env.sh" macos run

ensure_dependencies

cd "$ROOT_DIR/Source/Rust"
cargo build --target "$RUST_TARGET"
cp "target/$RUST_TARGET/debug/libdora_runtime.a" lib/macOS/libdora_runtime.a
xcodebuild ARCHS="$XCODE_ARCH" ONLY_ACTIVE_ARCH=NO -project ../../Projects/macOS/Dora.xcodeproj -target Dora -configuration Debug CONFIGURATION_BUILD_DIR=./build/Debug
stop_running_dora
../../Projects/macOS/build/Debug/Dora.app/Contents/MacOS/Dora --asset ../../Assets
