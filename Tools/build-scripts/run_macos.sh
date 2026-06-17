#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
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

"$SCRIPT_DIR/check_build_env.sh" macos run

if [ ! -f "$SCRIPT_DIR/../../Source/3rdParty/Wa/Lib/macOS/libwa.a" ]; then
	"$SCRIPT_DIR/build_lib_wa.sh" macos debug
fi

cd "$SCRIPT_DIR/../../Source/Rust"
cargo build --target "$RUST_TARGET"
cp "target/$RUST_TARGET/debug/libdora_runtime.a" lib/macOS/libdora_runtime.a
xcodebuild ARCHS="$XCODE_ARCH" ONLY_ACTIVE_ARCH=NO -project ../../Projects/macOS/Dora.xcodeproj -target Dora -configuration Debug CONFIGURATION_BUILD_DIR=./build/Debug
stop_running_dora
../../Projects/macOS/build/Debug/Dora.app/Contents/MacOS/Dora --asset ../../Assets
