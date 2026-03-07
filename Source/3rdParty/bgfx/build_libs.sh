#!/bin/bash
# bgfx/bimg/bx/shaderc 多架构构建脚本
# 用法: ./build_libs.sh [macos|ios|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 目标库列表
LIBS="bx bimg bimg_decode bgfx fcpp spirv_cross spirv_opt glslang glsl_optimizer shaderc_lib"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 清理构建目录
clean_build() {
    log_info "Cleaning build directory..."
    xmake f -c -y 2>/dev/null || true
}

# 编译指定平台和架构
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
    xmake -j8
}

# macOS: 编译 arm64 和 x86_64，合成 fat lib
build_macos() {
    log_info "=== Building macOS (Universal) ==="
    
    clean_build
    
    # 编译 arm64
    build_arch macosx arm64
    
    # 编译 x86_64
    xmake f -c -y
    build_arch macosx x86_64
    
    # 合成 fat lib
    log_info "Creating fat libraries..."
    mkdir -p build/macosx/universal
    for lib in $LIBS; do
        lipo -create \
            build/macosx/arm64/release/lib${lib}.a \
            build/macosx/x86_64/release/lib${lib}.a \
            -output build/macosx/universal/lib${lib}.a
    done
    
    log_info "macOS universal libraries created at: build/macosx/universal/"
    ls -lh build/macosx/universal/*.a
}

# iOS: 编译 device 和 simulator
build_ios() {
    log_info "=== Building iOS (Device + Simulator) ==="
    
    clean_build
    
    # 编译 device (arm64)
    build_arch iphoneos arm64 release
    
    # 编译 simulator x86_64
    log_info "Building simulator x86_64..."
    xmake f -c -y
    build_arch iphoneos x86_64 release --appledev=simulator
    
    # 编译 simulator arm64 (M1 Mac)
    log_info "Building simulator arm64..."
    xmake f -c -y
    build_arch iphoneos arm64 release --appledev=simulator
    
    # 创建输出目录
    mkdir -p build/ios/device
    mkdir -p build/ios/simulator
    
    # 复制 device 库
    log_info "Copying device libraries..."
    for lib in $LIBS; do
        cp build/iphoneos/arm64/release/lib${lib}.a build/ios/device/
    done
    
    # 合成 simulator fat lib (x86_64 + arm64)
    log_info "Creating simulator fat libraries..."
    for lib in $LIBS; do
        lipo -create \
            build/iphoneos/x86_64/release/lib${lib}.a \
            build/iphoneos/arm64/release/lib${lib}.a \
            -output build/ios/simulator/lib${lib}.a
    done
    
    log_info "iOS libraries created:"
    echo "  Device:     build/ios/device/"
    echo "  Simulator:  build/ios/simulator/"
    echo ""
    echo "  Note: Device and simulator both contain arm64, so they cannot be"
    echo "  merged into a single fat library. Use xcodebuild -create-xcframework."
    ls -lh build/ios/device/*.a | head -5
}

# Android: 编译 arm64-v8a、armeabi-v7a 和 x86_64
build_android() {
    log_info "=== Building Android (arm64-v8a + armeabi-v7a + x86_64) ==="
    
    # 检查 NDK 是否已配置
    if [ -z "$ANDROID_NDK_HOME" ] && [ -z "$NDK_ROOT" ]; then
        log_warn "ANDROID_NDK_HOME or NDK_ROOT not set, xmake will try to auto-detect NDK"
    fi
    
    clean_build
    
    # 编译 arm64-v8a
    log_info "Building arm64-v8a..."
    build_arch android arm64-v8a
    
    # 编译 armeabi-v7a
    log_info "Building armeabi-v7a..."
    xmake f -c -y
    build_arch android armeabi-v7a
    
    # 编译 x86_64 (for emulator)
    log_info "Building x86_64..."
    xmake f -c -y
    build_arch android x86_64
    
    # 创建输出目录
    mkdir -p build/android/arm64-v8a
    mkdir -p build/android/armeabi-v7a
    mkdir -p build/android/x86_64
    
    # 复制 arm64-v8a 库
    log_info "Copying arm64-v8a libraries..."
    for lib in $LIBS; do
        cp build/android/arm64-v8a/release/lib${lib}.a build/android/arm64-v8a/
    done
    
    # 复制 armeabi-v7a 库
    log_info "Copying armeabi-v7a libraries..."
    for lib in $LIBS; do
        cp build/android/armeabi-v7a/release/lib${lib}.a build/android/armeabi-v7a/
    done
    
    # 复制 x86_64 库
    log_info "Copying x86_64 libraries..."
    for lib in $LIBS; do
        cp build/android/x86_64/release/lib${lib}.a build/android/x86_64/
    done
    
    log_info "Android libraries created:"
    echo "  ARM64-v8a:   build/android/arm64-v8a/"
    echo "  ARM v7-a:    build/android/armeabi-v7a/"
    echo "  x86_64:      build/android/x86_64/"
    ls -lh build/android/arm64-v8a/*.a | head -5
}

# 显示帮助
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  macos    Build macOS universal libraries (x86_64 + arm64)"
    echo "  ios      Build iOS libraries (device + simulator)"
    echo "  android  Build Android libraries (arm64-v8a + armeabi-v7a + x86_64)"
    echo "  all      Build macOS, iOS and Android"
    echo "  clean    Clean build directory"
    echo "  help     Show this help"
    echo ""
    echo "Output directories:"
    echo "  macOS:"
    echo "    build/macosx/arm64/release/     - ARM64 library"
    echo "    build/macosx/x86_64/release/    - x86_64 library"
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
    echo ""
    echo "Note: For iOS, use xcodebuild -create-xcframework to create XCFramework"
    echo "      that includes both device and simulator libraries."
}

# 主入口
case "${1:-help}" in
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
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
