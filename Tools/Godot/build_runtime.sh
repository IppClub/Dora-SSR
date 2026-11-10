#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="${DORA_GODOT_BUILD_DIR:-$ROOT/build/godot-runtime}"
TARGET="${DORA_GODOT_TARGET:-template_debug}"
ARCH="${DORA_GODOT_ARCH:-arm64}"
case "$TARGET" in
    template_debug) OPTIMIZE=none; PACKAGE="$BUILD/package"; LOG="$BUILD/build.log" ;;
    template_release) OPTIMIZE=speed; PACKAGE="$BUILD/release/package"; LOG="$BUILD/build-release.log" ;;
    *) printf 'Unsupported DORA_GODOT_TARGET: %s\n' "$TARGET" >&2; exit 2 ;;
esac
if [[ -n "${DORA_GODOT_BUILD_DIR:-}" ]]; then PACKAGE="$BUILD/package"; LOG="$BUILD/build.log"; fi
mkdir -p "$BUILD"
[[ "$ARCH" == arm64 ]] || {
    printf 'Godot Metal runtime 1.0 supports macOS arm64 only: %s\n' "$ARCH" >&2
    exit 2
}
SOURCE="$ROOT/Source/3rdParty/Godot"
"${DORA_GODOT_XMAKE:-${DORA_XMAKE:-xmake}}" lua "$ROOT/Tools/Godot/prepare.lua" "$SOURCE"
build_arch() {
    local build_arch="$1" build_log="$2"
    local mode=debug suffix=/debug
    if [[ "$TARGET" == template_release ]]; then mode=release; suffix=; fi
    local config="$ROOT/build/godot-xmake/macos-config-$mode"
    local xmake="${DORA_GODOT_XMAKE:-${DORA_XMAKE:-xmake}}"
    XMAKE_CONFIGDIR="$config" "$xmake" f -P "$ROOT" -c -p macosx -a "$build_arch" -m "$mode" \
        --target_minver=11.0 --dora_godot_runtime=y --dora_godot_standalone=y >> "$build_log" 2>&1
    XMAKE_CONFIGDIR="$config" "$xmake" build -P "$ROOT" -j"${JOBS:-3}" godot-runtime >> "$build_log" 2>&1
    LIBRARY="$ROOT/build/godot-xmake${suffix}/lib/libdora_godot.dylib"
}

: > "$LOG"
build_arch "$ARCH" "$LOG"
printf 'Runtime: %s\n' "$LIBRARY"

"${DORA_GODOT_XMAKE:-${DORA_XMAKE:-xmake}}" lua "$ROOT/Tools/Godot/package_runtime.lua" --source "$SOURCE" \
    --library "$LIBRARY" --output "$PACKAGE" --build-target "$TARGET" --architecture "$ARCH" \
    --graphics-backend metal
