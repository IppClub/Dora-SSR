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
if [ "$BUILD_MODE" = "release" ]; then
	xcodebuild archive -project Projects/macOS/Dora.xcodeproj -scheme Dora -configuration Release -archivePath Projects/macOS/build/Release/dora.xcarchive -arch "$XCODE_ARCH" ONLY_ACTIVE_ARCH=NO

	echo "Built APP in 'Projects/macOS/build/Release/dora.xcarchive/Products/Applications'"
else
	xcodebuild ARCHS="$XCODE_ARCH" ONLY_ACTIVE_ARCH=NO -project Projects/macOS/Dora.xcodeproj -target Dora -configuration "$XCODE_CONFIGURATION"

	echo "Built APP in 'Projects/macOS/build/Debug'"
fi
