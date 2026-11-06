#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="${DORA_GODOT_BUILD_DIR:-$ROOT/build/godot-linux}"
SOURCE="$ROOT/Source/3rdParty/Godot"
ARCH="${DORA_GODOT_LINUX_ARCH:-$(uname -m)}"
TARGET="${DORA_GODOT_TARGET:-template_debug}"
XMAKE="${DORA_GODOT_XMAKE:-${DORA_XMAKE:-xmake}}"
case "$TARGET" in
    template_debug) OPTIMIZE=none ;;
    template_release) OPTIMIZE=speed ;;
    *) echo "Unsupported Godot target: $TARGET" >&2; exit 2 ;;
esac
case "$ARCH" in
    x86_64) PACKAGE_ARCH=x86_64 ;;
    arm64|aarch64) PACKAGE_ARCH=arm64 ;;
    *) echo "Unsupported Linux runtime architecture: $ARCH" >&2; exit 2 ;;
esac
[[ "$(uname -s)" == Linux ]] || { echo 'Linux host required' >&2; exit 1; }
mkdir -p "$BUILD"
python3 "$ROOT/Tools/Godot/prepare.py" "$SOURCE"
command -v "$XMAKE" >/dev/null 2>&1 || {
    echo "Configured xmake executable is missing: $XMAKE" >&2
    exit 1
}
XMAKE_VERSION_OUTPUT="$("$XMAKE" --version)"
XMAKE_VERSION="${XMAKE_VERSION_OUTPUT%%$'\n'*}"
[[ "$XMAKE_VERSION" =~ xmake\ v([0-9]+)\. ]] && (( BASH_REMATCH[1] >= 3 )) || {
    echo "Godot xmake migration requires xmake 3.x or newer: $XMAKE_VERSION" >&2
    exit 1
}
MODE=debug; SUFFIX=/debug
if [[ "$TARGET" == template_release ]]; then MODE=release; SUFFIX=; fi
CONFIG="$ROOT/build/godot-xmake/linux-config-$PACKAGE_ARCH-$MODE"
XMAKE_ARGS=(-c -p linux -a "$PACKAGE_ARCH" -m "$MODE" --dora_godot_runtime=y --dora_godot_standalone=y --ccache=n)
[[ -n "${DORA_GODOT_LINUX_CROSS:-}" ]] && XMAKE_ARGS+=("--cross=$DORA_GODOT_LINUX_CROSS")
[[ -n "${DORA_GODOT_LINUX_BIN:-}" ]] && XMAKE_ARGS+=("--bin=$DORA_GODOT_LINUX_BIN")
[[ -n "${DORA_GODOT_LINUX_CC:-}" ]] && XMAKE_ARGS+=("--cc=$DORA_GODOT_LINUX_CC")
[[ -n "${DORA_GODOT_LINUX_CXX:-}" ]] && XMAKE_ARGS+=("--cxx=$DORA_GODOT_LINUX_CXX")
[[ -n "${DORA_GODOT_LINUX_AR:-}" ]] && XMAKE_ARGS+=("--ar=$DORA_GODOT_LINUX_AR")
[[ -n "${DORA_GODOT_LINUX_RANLIB:-}" ]] && XMAKE_ARGS+=("--ranlib=$DORA_GODOT_LINUX_RANLIB")
: > "$BUILD/build.log"
XMAKE_CONFIGDIR="$CONFIG" "$XMAKE" f -P "$ROOT" "${XMAKE_ARGS[@]}" >> "$BUILD/build.log" 2>&1
XMAKE_CONFIGDIR="$CONFIG" "$XMAKE" build -P "$ROOT" -j "${JOBS:-3}" godot-runtime >> "$BUILD/build.log" 2>&1
LIBRARY="$ROOT/build/godot-xmake/linux/$PACKAGE_ARCH${SUFFIX}/lib/libdora_godot.so"
printf 'Runtime: %s\n' "$LIBRARY"

[[ -n "$LIBRARY" ]] || { echo "Missing $TARGET runtime library" >&2; exit 1; }
python3 "$ROOT/Tools/Godot/package_runtime.py" --source "$SOURCE" --library "$LIBRARY" \
    --output "$BUILD/package" --build-target "$TARGET" --architecture "$PACKAGE_ARCH" --graphics-backend egl --static-accesskit-sdk linux
