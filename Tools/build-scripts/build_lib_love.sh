#!/bin/bash
# Build the curated LOVE 11.5 Object/Proxy runtime used by Dora LoveNode.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOVE_DIR="$SCRIPT_DIR/../../Source/3rdParty/Love"
BUILD_MODE="release"
TARGET_ARCH="universal"
COMMAND=""

build_arch() {
	local platform="$1"
	local arch="$2"
	shift 2
	(
		cd "$LOVE_DIR"
		xmake f -c -p "$platform" -a "$arch" -m "$BUILD_MODE" -y "$@"
		xmake build -j 8 love
	)
}

copy_library() {
	local platform="$1"
	local arch="$2"
	local output_dir="$3"
	mkdir -p "$LOVE_DIR/$output_dir"
	cp "$LOVE_DIR/build/$platform/$arch/$BUILD_MODE/liblove.a" "$LOVE_DIR/$output_dir/liblove.a"
}

find_android_llvm_ar() {
	local candidates=()
	[ -n "${ANDROID_NDK_HOME:-}" ] && candidates+=("$ANDROID_NDK_HOME")
	[ -n "${ANDROID_NDK_ROOT:-}" ] && candidates+=("$ANDROID_NDK_ROOT")
	[ -n "${NDK_ROOT:-}" ] && candidates+=("$NDK_ROOT")
	local sdk_root="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}"
	candidates+=("$sdk_root/ndk-bundle")
	if [ -d "$sdk_root/ndk" ]; then
		while IFS= read -r ndk_dir; do candidates+=("$ndk_dir"); done \
			< <(find "$sdk_root/ndk" -mindepth 1 -maxdepth 1 -type d | sort -r)
	fi
	local ndk_dir
	for ndk_dir in "${candidates[@]}"; do
		[ -d "$ndk_dir" ] || continue
		local llvm_ar
		llvm_ar=$(find "$ndk_dir/toolchains/llvm/prebuilt" -path "*/bin/llvm-ar" -type f 2>/dev/null | head -n 1 || true)
		if [ -n "$llvm_ar" ] && [ -x "$llvm_ar" ]; then
			echo "$llvm_ar"
			return 0
		fi
	done
	return 1
}

build_macos() {
	if [ "$TARGET_ARCH" = "universal" ]; then
		build_arch macosx arm64
		build_arch macosx x86_64
		mkdir -p "$LOVE_DIR/Artifacts/macOS"
		lipo -create "$LOVE_DIR/build/macosx/arm64/$BUILD_MODE/liblove.a" "$LOVE_DIR/build/macosx/x86_64/$BUILD_MODE/liblove.a" -output "$LOVE_DIR/Artifacts/macOS/liblove.a"
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
	mkdir -p "$LOVE_DIR/Artifacts/iOS-Simulator"
	lipo -create "$LOVE_DIR/build/iphoneos/arm64/$BUILD_MODE/liblove.a" "$LOVE_DIR/build/iphoneos/x86_64/$BUILD_MODE/liblove.a" -output "$LOVE_DIR/Artifacts/iOS-Simulator/liblove.a"
}

build_android() {
	local android_options=()
	local android_ar
	if android_ar=$(find_android_llvm_ar); then
		android_options+=("--ar=$android_ar")
	else
		echo "Android llvm-ar was not found" >&2
		exit 1
	fi
	for arch in arm64-v8a armeabi-v7a x86_64; do
		build_arch android "$arch" "${android_options[@]}"
		copy_library android "$arch" "Artifacts/Android/$arch"
	done
}

build_linux() {
	if [ "$(uname -s)" != "Linux" ]; then
		echo "Linux LOVE build must run on a Linux host" >&2
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
