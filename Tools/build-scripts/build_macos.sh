#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="${1:-debug}"
MACHINE_ARCH="$(uname -m)"

case "$MACHINE_ARCH" in
	arm64|aarch64)
		XCODE_ARCH="arm64"
		;;
	x86_64)
		XCODE_ARCH="x86_64"
		;;
	*)
		echo "Unsupported macOS architecture: $MACHINE_ARCH" >&2
		exit 1
		;;
esac

case "$BUILD_MODE" in
	debug|--debug|-d)
		BUILD_MODE="debug"
		XCODE_CONFIGURATION="Debug"
		;;
	release|--release|-r)
		BUILD_MODE="release"
		XCODE_CONFIGURATION="Release"
		;;
	*)
		echo "Usage: $0 [debug|release]" >&2
		exit 1
		;;
esac

"$SCRIPT_DIR/build_lib_macos.sh" "$BUILD_MODE" "$XCODE_ARCH"

cd "$SCRIPT_DIR/../.."
cmake -S Projects/macOS -B Projects/macOS/build-cmake -G Xcode \
	-DCMAKE_OSX_ARCHITECTURES="$XCODE_ARCH" \
	-DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO
cmake --build Projects/macOS/build-cmake --config "$XCODE_CONFIGURATION" --target Dora -j 8
echo "Built APP in 'Projects/macOS/build-cmake/$XCODE_CONFIGURATION/Dora.app'"
