#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$ROOT/build/godot-runtime"
TARGET="${DORA_GODOT_TARGET:-template_debug}"
ARCH="${DORA_GODOT_ARCH:-arm64}"
case "$TARGET" in
    template_debug) OPTIMIZE=none; PACKAGE="$BUILD/package"; LOG="$BUILD/build.log" ;;
    template_release) OPTIMIZE=speed; PACKAGE="$BUILD/release/package"; LOG="$BUILD/build-release.log" ;;
    *) printf 'Unsupported DORA_GODOT_TARGET: %s\n' "$TARGET" >&2; exit 2 ;;
esac
[[ "$ARCH" == arm64 ]] || {
    printf 'Godot Metal runtime 1.0 supports macOS arm64 only: %s\n' "$ARCH" >&2
    exit 2
}
SOURCE="$ROOT/Source/3rdParty/Godot"
python3 "$ROOT/Tools/Godot/prepare.py" "$SOURCE"
build_arch() {
    local build_arch="$1" build_log="$2"
    if [[ "$TARGET" == template_release ]]; then
        local config="$ROOT/build/godot-xmake/macos-config"
        XMAKE_CONFIGDIR="$config" xmake f -c -p macosx -a "$build_arch" -m release \
            --target_minver=11.0 --dora_godot_runtime=y >> "$build_log" 2>&1
        XMAKE_CONFIGDIR="$config" xmake build -j"${JOBS:-3}" godot-runtime >> "$build_log" 2>&1
        LIBRARY="$ROOT/build/godot-xmake/lib/libdora_godot.dylib"
        return
    fi
    if [[ ! -x "$BUILD/venv/bin/scons" ]]; then
        python3 -m venv "$BUILD/venv"
        "$BUILD/venv/bin/pip" install scons==4.11.1
    fi
    # Keep standard Godot runtime modules: real projects may use physics,
    # importers, text shaping and codecs omitted from the first probe.
    (cd "$SOURCE" && "$BUILD/venv/bin/scons" platform=macos arch="$build_arch" target="$TARGET" \
        library_type=shared_library linkflags=-Wl,-exported_symbols_list,dora_bridge.exports \
        disable_path_overrides=no vulkan=no opengl3=no metal=yes \
        optimize="$OPTIMIZE" debug_symbols=no use_lto=no -j"${JOBS:-3}") >> "$build_log" 2>&1
    LIBRARY="$SOURCE/bin/libgodot.macos.$TARGET.$build_arch.dylib"
}

: > "$LOG"
build_arch "$ARCH" "$LOG"
printf 'Runtime: %s\n' "$LIBRARY"

python3 "$ROOT/Tools/Godot/package_runtime.py" --source "$SOURCE" \
    --library "$LIBRARY" --output "$PACKAGE" --build-target "$TARGET" --architecture "$ARCH" \
    --graphics-backend metal
