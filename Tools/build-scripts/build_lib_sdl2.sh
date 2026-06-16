#!/bin/bash
# SDL2 multi-platform build script.
# Usage: ./build_lib_sdl2.sh [macos|ios|android|all] [--debug]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDL_DIR="$SCRIPT_DIR/../../Source/3rdParty/SDL2"
cd "$SDL_DIR"

BUILD_MODE="release"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
	echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
	echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

clean_build() {
	local platform=${1:-}
	if [ -n "$platform" ]; then
		xmake f -c -p "$platform" -y 2>/dev/null || true
	else
		xmake f -c -y 2>/dev/null || true
	fi
}

build_arch() {
	local platform=$1
	local arch=$2
	local mode=${3:-release}
	shift 3
	local extra_opts="$@"

	log_info "Building SDL2 for $platform ($arch) $mode ${extra_opts}"
	xmake f -p "$platform" -a "$arch" -m "$mode" -y $extra_opts
	xmake build -j 8 SDL2
}

build_macos() {
	log_info "=== Building SDL2 macOS (Universal) ==="
	clean_build macosx
	build_arch macosx arm64 "$BUILD_MODE"
	clean_build macosx
	build_arch macosx x86_64 "$BUILD_MODE"

	mkdir -p Lib/macOS
	lipo -create \
		build/macosx/arm64/${BUILD_MODE}/libSDL2.a \
		build/macosx/x86_64/${BUILD_MODE}/libSDL2.a \
		-output Lib/macOS/libSDL2.a

	log_info "Created Lib/macOS/libSDL2.a"
	file Lib/macOS/libSDL2.a
}

build_ios() {
	log_info "=== Building SDL2 iOS (Device + Simulator) ==="
	clean_build iphoneos
	build_arch iphoneos arm64 "$BUILD_MODE"

	clean_build iphoneos
	build_arch iphoneos x86_64 "$BUILD_MODE" --appledev=simulator

	clean_build iphoneos
	build_arch iphoneos arm64 "$BUILD_MODE" --appledev=simulator

	mkdir -p Lib/iOS Lib/iOS-Simulator
	cp build/iphoneos/arm64/${BUILD_MODE}/libSDL2.a Lib/iOS/libSDL2.a
	lipo -create \
		build/iphoneos/x86_64/${BUILD_MODE}/libSDL2.a \
		build/iphoneos/arm64/${BUILD_MODE}/libSDL2.a \
		-output Lib/iOS-Simulator/libSDL2.a

	log_info "Created Lib/iOS/libSDL2.a and Lib/iOS-Simulator/libSDL2.a"
	file Lib/iOS/libSDL2.a
	file Lib/iOS-Simulator/libSDL2.a
}

build_android() {
	log_info "=== Building SDL2 Android (arm64-v8a + armeabi-v7a + x86_64) ==="
	if [ -z "$ANDROID_NDK_HOME" ] && [ -z "$NDK_ROOT" ]; then
		log_warn "ANDROID_NDK_HOME or NDK_ROOT not set, xmake will try to auto-detect NDK"
	fi

	for arch in arm64-v8a armeabi-v7a x86_64; do
		clean_build android
		build_arch android "$arch" "$BUILD_MODE"
		mkdir -p "Lib/Android/$arch"
		cp "build/android/$arch/${BUILD_MODE}/libSDL2.so" "Lib/Android/$arch/libSDL2.so"
	done

	log_info "Created Android SDL2 shared libraries under Lib/Android/"
	find Lib/Android -name libSDL2.so -exec file {} \;
}

show_help() {
	echo "Usage: $0 [command] [--debug]"
	echo ""
	echo "Commands:"
	echo "  macos    Build macOS universal SDL2 library"
	echo "  ios      Build iOS device and simulator SDL2 libraries"
	echo "  android  Build Android SDL2 shared libraries"
	echo "  all      Build macOS, iOS and Android"
	echo "  clean    Clean xmake configuration"
	echo "  help     Show this help"
	echo ""
	echo "Options:"
	echo "  --debug, -d     Build debug libraries"
	echo "  --release, -r   Build release libraries"
}

COMMAND=""
for arg in "$@"; do
	case "$arg" in
		--debug|-d)
			BUILD_MODE="debug"
			;;
		--release|-r)
			BUILD_MODE="release"
			;;
		macos|ios|android|all|clean|help|--help|-h)
			if [ -n "$COMMAND" ]; then
				log_error "Multiple commands specified: $COMMAND and $arg"
				show_help
				exit 1
			fi
			COMMAND="$arg"
			;;
		*)
			log_error "Unknown argument: $arg"
			show_help
			exit 1
			;;
	esac
done

COMMAND=${COMMAND:-macos}

case "$COMMAND" in
	macos)
		build_macos
		;;
	ios)
		build_ios
		;;
	android)
		build_android
		;;
	all)
		build_macos
		build_ios
		build_android
		;;
	clean)
		clean_build
		;;
	help|--help|-h)
		show_help
		;;
esac
