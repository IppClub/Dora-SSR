#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="${1:-debug}"

case "$BUILD_MODE" in
	debug|--debug|-d)
		BUILD_MODE="debug"
		GRADLE_TASK="assembleDebug"
		OUTPUT_DIR="debug"
		;;
	release|--release|-r)
		BUILD_MODE="release"
		GRADLE_TASK="assembleRelease"
		OUTPUT_DIR="release"
		;;
	*)
		echo "Usage: $0 [debug|release]" >&2
		exit 1
		;;
esac

"$SCRIPT_DIR/build_lib_android.sh" "$BUILD_MODE"

cd "$SCRIPT_DIR/../../Projects/Android/Dora"
./gradlew "$GRADLE_TASK"

echo "Built APP in 'Projects/Android/Dora/app/build/outputs/apk/$OUTPUT_DIR'"
