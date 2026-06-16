#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="${1:-debug}"

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

"$SCRIPT_DIR/build_lib_ios.sh" "$BUILD_MODE"

cd "$SCRIPT_DIR/../.."
xcodebuild ARCHS=arm64 ONLY_ACTIVE_ARCH=NO -project Projects/iOS/Dora.xcodeproj -configuration "$XCODE_CONFIGURATION" -target Simulator -sdk iphonesimulator

echo "Built APP for iOS Simulator ($XCODE_CONFIGURATION)"
