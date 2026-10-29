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
SOURCE="$BUILD/deps/godot-4.6-stable"
ARCHIVE="$BUILD/deps/godot-4.6-stable.tar.gz"
mkdir -p "$BUILD/deps"
if [[ ! -f "$ARCHIVE" ]]; then
    if [[ -f "$ROOT/build/godot-metal-probe/deps/godot-4.6-stable.tar.gz" ]]; then
        cp "$ROOT/build/godot-metal-probe/deps/godot-4.6-stable.tar.gz" "$ARCHIVE"
    else
        curl -fL --retry 2 https://codeload.github.com/godotengine/godot/tar.gz/refs/tags/4.6-stable -o "$ARCHIVE"
    fi
fi
printf '%s  %s\n' b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0 "$ARCHIVE" | shasum -a 256 -c -
if [[ ! -d "$SOURCE" ]]; then tar -xzf "$ARCHIVE" -C "$BUILD/deps"; fi
if [[ ! -x "$BUILD/venv/bin/scons" ]]; then
    python3 -m venv "$BUILD/venv"
    "$BUILD/venv/bin/pip" install scons==4.11.1
fi
python3 "$ROOT/Tools/Godot/prepare.py" "$SOURCE"
cd "$SOURCE"
build_arch() {
    local build_arch="$1" build_log="$2"
    # Keep standard Godot runtime modules: real projects may use physics,
    # importers, text shaping and codecs omitted from the first probe.
    "$BUILD/venv/bin/scons" platform=macos arch="$build_arch" target="$TARGET" \
        library_type=shared_library linkflags=-Wl,-exported_symbols_list,dora_bridge.exports \
        disable_path_overrides=no vulkan=no opengl3=no metal=yes \
        optimize="$OPTIMIZE" debug_symbols=no use_lto=no -j"${JOBS:-3}" > "$build_log" 2>&1
}

build_arch "$ARCH" "$LOG"
LIBRARY="$SOURCE/bin/libgodot.macos.$TARGET.$ARCH.dylib"
printf 'Runtime: %s\n' "$LIBRARY"

python3 "$ROOT/Tools/Godot/package_runtime.py" --source "$SOURCE" \
    --library "$LIBRARY" --output "$PACKAGE" --build-target "$TARGET" --architecture "$ARCH"
