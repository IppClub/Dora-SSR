#!/bin/bash
# Build the portable Theora decoder. libogg is already built by Source/3rdParty/ogg/OggSources.c.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEORA_DIR="$SCRIPT_DIR/../../Source/3rdParty/theora"
BUILD_MODE="release"
TARGET_ARCH="universal"
COMMAND=""

build_arch() {
	local platform="$1"
	local arch="$2"
	shift 2
	(
		cd "$THEORA_DIR"
		xmake f -c -p "$platform" -a "$arch" -m "$BUILD_MODE" -y "$@"
		xmake build -j 8 theoradec
	)
}

copy_library() {
	local platform="$1"
	local arch="$2"
	local output_dir="$3"
	mkdir -p "$THEORA_DIR/$output_dir"
	cp "$THEORA_DIR/build/$platform/$arch/$BUILD_MODE/libtheoradec.a" "$THEORA_DIR/$output_dir/libtheoradec.a"
}

build_macos() {
	if [ "$TARGET_ARCH" = "universal" ]; then
		build_arch macosx arm64
		build_arch macosx x86_64
		mkdir -p "$THEORA_DIR/Artifacts/macOS"
		lipo -create "$THEORA_DIR/build/macosx/arm64/$BUILD_MODE/libtheoradec.a" "$THEORA_DIR/build/macosx/x86_64/$BUILD_MODE/libtheoradec.a" -output "$THEORA_DIR/Artifacts/macOS/libtheoradec.a"
	else
		build_arch macosx "$TARGET_ARCH"
		copy_library macosx "$TARGET_ARCH" Artifacts/macOS
	fi
}

build_ios() {
	build_arch iphoneos arm64
	copy_library iphoneos arm64 Artifacts/iOS
	build_arch iphoneos arm64 --appledev=simulator
	build_arch iphoneos x86_64 --appledev=simulator
	mkdir -p "$THEORA_DIR/Artifacts/iOS-Simulator"
	lipo -create "$THEORA_DIR/build/iphoneos/arm64/$BUILD_MODE/libtheoradec.a" "$THEORA_DIR/build/iphoneos/x86_64/$BUILD_MODE/libtheoradec.a" -output "$THEORA_DIR/Artifacts/iOS-Simulator/libtheoradec.a"
}

build_android() {
	for arch in arm64-v8a armeabi-v7a x86_64; do
		build_arch android "$arch"
		copy_library android "$arch" "Artifacts/Android/$arch"
	done
}

build_linux() {
	if [ "$(uname -s)" != "Linux" ]; then
		echo "Linux Theora build must run on a Linux host" >&2
		exit 1
	fi
	local arch
	case "$(uname -m)" in
		x86_64|amd64) arch=x86_64 ;;
		aarch64|arm64) arch=aarch64 ;;
		*) echo "Unsupported Linux architecture: $(uname -m)" >&2; exit 1 ;;
	esac
	build_arch linux "$arch"
	copy_library linux "$arch" "Artifacts/Linux/$arch"
}

for arg in "$@"; do
	case "$arg" in
		--debug|-d) BUILD_MODE=debug ;;
		--release|-r) BUILD_MODE=release ;;
		arm64|aarch64) TARGET_ARCH=arm64 ;;
		x86_64|universal) TARGET_ARCH="$arg" ;;
		macos|ios|android|linux|all) COMMAND="$arg" ;;
		*) echo "Usage: $0 [macos|ios|android|linux|all] [--debug|--release] [arm64|x86_64|universal]" >&2; exit 1 ;;
	esac
done

case "${COMMAND:-macos}" in
	macos) build_macos ;;
	ios) build_ios ;;
	android) build_android ;;
	linux) build_linux ;;
	all) build_macos; build_ios; build_android; build_linux ;;
esac
