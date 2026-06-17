#!/bin/bash

set -euo pipefail

PLATFORM="${1:-}"
SCOPE="${2:-build}"
MISSING=()

usage() {
	echo "Usage: $0 <macos|ios|linux|android> [build|run|lib]" >&2
	exit 1
}

require_command() {
	local command_name="$1"
	local hint="${2:-}"

	if ! command -v "$command_name" >/dev/null 2>&1; then
		if [ -n "$hint" ]; then
			MISSING+=("$command_name ($hint)")
		else
			MISSING+=("$command_name")
		fi
	fi
}

case "$PLATFORM" in
	macos|ios|linux|android)
		;;
	*)
		usage
		;;
esac

require_command go "required for Wa"
require_command cargo "required for Rust runtime"
require_command rustup "required for Rust targets"

if [ "$SCOPE" != "run" ]; then
	require_command xmake "required for SDL2/bgfx"
fi

case "$PLATFORM" in
	macos)
		require_command xcodebuild "install Xcode command line tools"
		require_command xcrun "install Xcode command line tools"
		require_command lipo "install Xcode command line tools"
		;;
	ios)
		require_command xcodebuild "install Xcode"
		require_command xcrun "install Xcode"
		require_command lipo "install Xcode"
		;;
	linux)
		require_command cmake "required for Linux engine build and SDL2"
		require_command make "required for Linux engine build"
		require_command pkg-config "required for native dependencies"
		require_command cc "required C compiler"
		require_command c++ "required C++ compiler"
		;;
	android)
		require_command java "required for Gradle/Android build"
		require_command unzip "required for Wa Android AAR trimming"
		require_command zip "required for Wa Android AAR trimming"
		if [ -z "${ANDROID_NDK_HOME:-}" ] && [ -z "${NDK_ROOT:-}" ] && [ -z "${ANDROID_NDK_ROOT:-}" ]; then
			echo "[WARN] ANDROID_NDK_HOME, ANDROID_NDK_ROOT, or NDK_ROOT is not set; xmake/Gradle will try to auto-detect the NDK." >&2
		fi
		;;
esac

if [ "${#MISSING[@]}" -gt 0 ]; then
	echo "Missing build environment tools for $PLATFORM ($SCOPE):" >&2
	for item in "${MISSING[@]}"; do
		echo "  - $item" >&2
	done
	echo "Install the missing tools and re-run the command." >&2
	exit 1
fi
