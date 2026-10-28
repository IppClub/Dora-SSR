#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$ROOT/build/godot-runtime"
TARGET="${DORA_GODOT_TARGET:-template_debug}"
case "$TARGET" in
    template_debug) OPTIMIZE=none; PACKAGE="$BUILD/package"; LOG="$BUILD/build.log" ;;
    template_release) OPTIMIZE=speed; PACKAGE="$BUILD/release/package"; LOG="$BUILD/build-release.log" ;;
    *) printf 'Unsupported DORA_GODOT_TARGET: %s\n' "$TARGET" >&2; exit 2 ;;
esac
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
# Keep standard Godot runtime modules: real projects may use physics, importers,
# text shaping and codecs that were deliberately omitted from the first probe.
"$BUILD/venv/bin/scons" platform=macos arch=arm64 target="$TARGET" \
    library_type=shared_library linkflags=-Wl,-exported_symbols_list,dora_bridge.exports \
    disable_path_overrides=no vulkan=no opengl3=no metal=yes \
    optimize="$OPTIMIZE" debug_symbols=no use_lto=no -j"${JOBS:-3}" > "$LOG" 2>&1
printf 'Runtime: %s\n' "$SOURCE/bin/libgodot.macos.$TARGET.arm64.dylib"

python3 "$ROOT/Tools/Godot/package_runtime.py" --source "$SOURCE" \
    --library "$SOURCE/bin/libgodot.macos.$TARGET.arm64.dylib" --output "$PACKAGE" --build-target "$TARGET"
