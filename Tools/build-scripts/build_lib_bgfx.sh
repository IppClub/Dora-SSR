#!/bin/bash
# bgfx/bimg/bx/shaderc 多架构构建脚本
# 用法: ./build_lib_bgfx.sh [macos|ios|android|all] [--debug]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../Source/3rdParty/bgfx"

BUILD_MODE="release"

get_libs_for_platform() {
    local platform=$1
    local libs="bx bimg bimg_decode bgfx fcpp shaderc-lib"

    case "$platform" in
        macosx|iphoneos)
            libs="$libs spirv-cross spirv-opt glslang"
            ;;
        linux|android)
            libs="$libs glsl_optimizer"
            ;;
    esac

    echo "$libs"
}

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
    log_info "Cleaning build directory..."
    xmake f -c -y 2>/dev/null || true
}

build_arch() {
    local platform=$1
    local arch=$2
    local mode=${3:-release}
    shift 2
    if [ $# -gt 0 ]; then
        shift
    fi
    local extra_opts="$@"

    log_info "Building for $platform ($arch) ${extra_opts}..."
    xmake f -p "$platform" -a "$arch" -m "$mode" -y $extra_opts
    xmake build -j 8 bgfx
    xmake build -j 8 shaderc-lib
}

build_macos() {
    log_info "=== Building macOS (Universal) ==="
    local libs
    libs=$(get_libs_for_platform "macosx")

    clean_build
    build_arch macosx arm64 "$BUILD_MODE"
    xmake f -c -y
    build_arch macosx x86_64 "$BUILD_MODE"

    log_info "Creating fat libraries..."
    mkdir -p build/macosx/universal
    for lib in $libs; do
        lipo -create \
            build/macosx/arm64/${BUILD_MODE}/lib${lib}.a \
            build/macosx/x86_64/${BUILD_MODE}/lib${lib}.a \
            -output build/macosx/universal/lib${lib}.a
    done

    log_info "macOS universal libraries created at: build/macosx/universal/"
    ls -lh build/macosx/universal/*.a
}

build_ios() {
    log_info "=== Building iOS (Device + Simulator) ==="
    local libs
    libs=$(get_libs_for_platform "iphoneos")

    clean_build
    build_arch iphoneos arm64 "$BUILD_MODE"

    log_info "Building simulator x86_64..."
    xmake f -c -y
    build_arch iphoneos x86_64 "$BUILD_MODE" --appledev=simulator

    log_info "Building simulator arm64..."
    xmake f -c -y
    build_arch iphoneos arm64 "$BUILD_MODE" --appledev=simulator

    mkdir -p build/ios/device
    mkdir -p build/ios/simulator

    log_info "Copying device libraries..."
    for lib in $libs; do
        cp build/iphoneos/arm64/${BUILD_MODE}/lib${lib}.a build/ios/device/
    done

    log_info "Creating simulator fat libraries..."
    for lib in $libs; do
        lipo -create \
            build/iphoneos/x86_64/${BUILD_MODE}/lib${lib}.a \
            build/iphoneos/arm64/${BUILD_MODE}/lib${lib}.a \
            -output build/ios/simulator/lib${lib}.a
    done

    log_info "iOS libraries created:"
    echo "  Device:     build/ios/device/"
    echo "  Simulator:  build/ios/simulator/"
    echo ""
    echo "  Note: Device and simulator both contain arm64, so they are kept"
    echo "  as separate outputs instead of being merged into a single fat library."
    ls -lh build/ios/device/*.a | head -5
}

build_android() {
    log_info "=== Building Android (arm64-v8a + armeabi-v7a + x86_64) ==="
    local libs
    libs=$(get_libs_for_platform "android")

    if [ -z "$ANDROID_NDK_HOME" ] && [ -z "$NDK_ROOT" ]; then
        log_warn "ANDROID_NDK_HOME or NDK_ROOT not set, xmake will try to auto-detect NDK"
    fi

    clean_build

    log_info "Building arm64-v8a..."
    build_arch android arm64-v8a "$BUILD_MODE"

    log_info "Building armeabi-v7a..."
    xmake f -c -y
    build_arch android armeabi-v7a "$BUILD_MODE"

    log_info "Building x86_64..."
    xmake f -c -y
    build_arch android x86_64 "$BUILD_MODE"

    mkdir -p build/android/arm64-v8a
    mkdir -p build/android/armeabi-v7a
    mkdir -p build/android/x86_64

    log_info "Copying arm64-v8a libraries..."
    for lib in $libs; do
        cp build/android/arm64-v8a/${BUILD_MODE}/lib${lib}.a build/android/arm64-v8a/
    done

    log_info "Copying armeabi-v7a libraries..."
    for lib in $libs; do
        cp build/android/armeabi-v7a/${BUILD_MODE}/lib${lib}.a build/android/armeabi-v7a/
    done

    log_info "Copying x86_64 libraries..."
    for lib in $libs; do
        cp build/android/x86_64/${BUILD_MODE}/lib${lib}.a build/android/x86_64/
    done

    log_info "Android libraries created:"
    echo "  ARM64-v8a:   build/android/arm64-v8a/"
    echo "  ARM v7-a:    build/android/armeabi-v7a/"
    echo "  x86_64:      build/android/x86_64/"
    ls -lh build/android/arm64-v8a/*.a | head -5
}

show_help() {
    echo "Usage: $0 [command] [--debug]"
    echo ""
    echo "Commands:"
    echo "  macos    Build macOS universal libraries (x86_64 + arm64)"
    echo "  ios      Build iOS libraries (device + simulator)"
    echo "  android  Build Android libraries (arm64-v8a + armeabi-v7a + x86_64)"
    echo "  all      Build macOS, iOS and Android"
    echo "  clean    Clean build directory"
    echo "  help     Show this help"
    echo ""
    echo "Options:"
    echo "  --debug, -d   Build debug libraries (default: release)"
    echo ""
    echo "Output directories:"
    echo "  macOS:"
    echo "    build/macosx/arm64/<mode>/      - ARM64 library"
    echo "    build/macosx/x86_64/<mode>/     - x86_64 library"
    echo "    build/macosx/universal/         - Fat library (x86_64 + arm64)"
    echo ""
    echo "  iOS:"
    echo "    build/ios/device/               - Device only (arm64)"
    echo "    build/ios/simulator/            - Simulator (x86_64 + arm64)"
    echo ""
    echo "  Android:"
    echo "    build/android/arm64-v8a/        - ARM64 library"
    echo "    build/android/armeabi-v7a/      - ARM v7-a library"
    echo "    build/android/x86_64/           - x86_64 library (emulator)"
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

case "${COMMAND:-help}" in
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
        echo ""
        build_ios
        echo ""
        build_android
        ;;
    clean)
        clean_build
        rm -rf build
        log_info "Build directory cleaned."
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: ${COMMAND:-}"
        show_help
        exit 1
        ;;
esac
