#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
WA_DIR="$PROJECT_DIR/Source/3rdParty/Wa/Source"
OUTPUT_DIR="$PROJECT_DIR/Source/3rdParty/Wa/Lib"
PLATFORM="${1:-}"
BUILD_MODE="${2:-debug}"
GOMOBILE_VERSION="v0.0.0-20250606033058-a2a15c67f36f"

usage() {
	echo "Usage: $0 <macos|ios|linux|android|all> [debug|release]" >&2
	exit 1
}

case "$PLATFORM" in
	macos|ios|linux|android|all)
		;;
	*)
		usage
		;;
esac

case "$BUILD_MODE" in
	debug|--debug|-d)
		BUILD_MODE="debug"
		GO_LDFLAGS="-ldflags=-s -w"
		;;
	release|--release|-r)
		BUILD_MODE="release"
		GO_LDFLAGS="-ldflags=-s -w"
		;;
	*)
		usage
		;;
esac

if [ ! -f "$WA_DIR/go.mod" ]; then
	echo "Wa source is missing: $WA_DIR" >&2
	echo "Run Tools/build-scripts/sync_wa_source.sh first." >&2
	exit 1
fi

build_archive() {
	local goos="$1"
	local goarch="$2"
	local output="$3"
	local build_dir="$WA_DIR/.build/$goos-$goarch"

	mkdir -p "$(dirname "$output")" "$build_dir"
	(
		cd "$WA_DIR"
		GOOS="$goos" GOARCH="$goarch" CGO_ENABLED=1 GOFLAGS="-mod=vendor" \
			go build -trimpath -buildmode=c-archive ${GO_LDFLAGS:+"$GO_LDFLAGS"} -o "$build_dir/libwa.a"
	)

	if [ ! -f "$output" ] || ! cmp -s "$build_dir/libwa.a" "$output"; then
		cp "$build_dir/libwa.a" "$output"
	fi
}

build_macos() {
	CGO_CFLAGS="-mmacosx-version-min=11.3" CGO_LDFLAGS="-mmacosx-version-min=11.3" \
		build_archive darwin arm64 "$WA_DIR/.build/darwin-arm64/libwa.a"
	CGO_CFLAGS="-mmacosx-version-min=11.3" CGO_LDFLAGS="-mmacosx-version-min=11.3" \
		build_archive darwin amd64 "$WA_DIR/.build/darwin-amd64/libwa.a"
	mkdir -p "$OUTPUT_DIR/macOS"
	lipo -create "$WA_DIR/.build/darwin-arm64/libwa.a" "$WA_DIR/.build/darwin-amd64/libwa.a" -output "$OUTPUT_DIR/macOS/libwa.a"
}

build_ios() {
	local iphoneos_sdk
	local simulator_sdk

	iphoneos_sdk="$(xcrun --sdk iphoneos --show-sdk-path)"
	simulator_sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"

	CGO_CFLAGS="-isysroot $iphoneos_sdk -miphoneos-version-min=13.0" \
		CGO_LDFLAGS="-isysroot $iphoneos_sdk -miphoneos-version-min=13.0" \
		build_archive ios arm64 "$OUTPUT_DIR/iOS/libwa.a"
	CGO_CFLAGS="-isysroot $simulator_sdk -mios-simulator-version-min=13.0" \
		CGO_LDFLAGS="-isysroot $simulator_sdk -mios-simulator-version-min=13.0" \
		build_archive darwin amd64 "$WA_DIR/.build/ios-amd64/libwa.a"
	CGO_CFLAGS="-isysroot $simulator_sdk -mios-simulator-version-min=13.0" \
		CGO_LDFLAGS="-isysroot $simulator_sdk -mios-simulator-version-min=13.0" \
		build_archive ios arm64 "$WA_DIR/.build/ios-arm64-simulator/libwa.a"
	mkdir -p "$OUTPUT_DIR/iOS-Simulator"
	lipo -create "$WA_DIR/.build/ios-arm64-simulator/libwa.a" "$WA_DIR/.build/ios-amd64/libwa.a" -output "$OUTPUT_DIR/iOS-Simulator/libwa.a"
}

build_linux() {
	local arch

	case "$(uname -m)" in
		x86_64)
			arch="amd64"
			;;
		aarch64|arm64)
			arch="arm64"
			;;
		*)
			echo "Unsupported Linux architecture: $(uname -m)" >&2
			exit 1
			;;
	esac

	if [ "$arch" = "arm64" ]; then
		build_archive linux arm64 "$OUTPUT_DIR/Linux/aarch64/libwa.a"
	else
		build_archive linux amd64 "$OUTPUT_DIR/Linux/amd64/libwa.a"
	fi
}

ensure_gomobile() {
	if ! command -v gomobile >/dev/null 2>&1; then
		go install "golang.org/x/mobile/cmd/gomobile@$GOMOBILE_VERSION"
	fi
	gomobile init
}

build_android() {
	local temp_dir

	ensure_gomobile
	temp_dir="$(mktemp -d)"
	trap 'rm -rf "$temp_dir"' RETURN
	cp -R "$WA_DIR/." "$temp_dir/wa"
	mv "$temp_dir/wa/wa.gomobile" "$temp_dir/wa/wa.go"
	rm -f "$temp_dir/wa/main.go"
	(
		cd "$temp_dir/wa"
		GOFLAGS="-mod=vendor" gomobile bind -v -androidapi 21 -o wa.aar -target=android .
	)

	mkdir -p "$OUTPUT_DIR/Android"
	rm -rf "$temp_dir/aar"
	mkdir -p "$temp_dir/aar"
	(
		cd "$temp_dir/aar"
		unzip -q "$temp_dir/wa/wa.aar"
		rm -rf jni/x86
		zip -qr "$OUTPUT_DIR/Android/wa.aar" .
	)
}

case "$PLATFORM" in
	macos)
		build_macos
		;;
	ios)
		build_ios
		;;
	linux)
		build_linux
		;;
	android)
		build_android
		;;
	all)
		build_macos
		build_ios
		build_linux
		build_android
		;;
esac
