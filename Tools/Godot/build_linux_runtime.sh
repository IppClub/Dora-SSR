#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="${DORA_GODOT_BUILD_DIR:-$ROOT/build/godot-linux}"
SOURCE="$BUILD/deps/godot-4.6-stable"
ARCHIVE="$BUILD/deps/godot-4.6-stable.tar.gz"
ARCH="${DORA_GODOT_LINUX_ARCH:-$(uname -m)}"
TARGET="${DORA_GODOT_TARGET:-template_debug}"
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
mkdir -p "$BUILD/deps"
if [[ ! -f "$ARCHIVE" ]]; then
    curl -fL --retry 2 "${DORA_GODOT_ARCHIVE_URL:-https://codeload.github.com/godotengine/godot/tar.gz/refs/tags/4.6-stable}" -o "$ARCHIVE"
fi
printf '%s  %s\n' b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0 "$ARCHIVE" | sha256sum -c -
if [[ ! -d "$SOURCE" ]]; then tar -xzf "$ARCHIVE" -C "$BUILD/deps"; fi
SCONS="${DORA_GODOT_SCONS:-$BUILD/venv/bin/scons}"
if [[ -n "${DORA_GODOT_SCONS:-}" && ! -x "$SCONS" ]]; then
    echo "Configured SCons executable is missing: $SCONS" >&2
    exit 1
fi
if [[ -z "${DORA_GODOT_SCONS:-}" && ! -x "$SCONS" ]]; then
    python3 -m venv "$BUILD/venv"
    "$BUILD/venv/bin/pip" install scons==4.11.1
fi
python3 "$ROOT/Tools/Godot/prepare.py" "$SOURCE"
cd "$SOURCE"
COMPILER=()
[[ -n "${DORA_GODOT_LINUX_CC:-}" ]] && COMPILER+=("CC=$DORA_GODOT_LINUX_CC")
[[ -n "${DORA_GODOT_LINUX_CXX:-}" ]] && COMPILER+=("CXX=$DORA_GODOT_LINUX_CXX")
[[ -n "${DORA_GODOT_LINUX_AR:-}" ]] && COMPILER+=("AR=$DORA_GODOT_LINUX_AR")
[[ -n "${DORA_GODOT_LINUX_RANLIB:-}" ]] && COMPILER+=("RANLIB=$DORA_GODOT_LINUX_RANLIB")
"$SCONS" platform=linuxbsd arch="$ARCH" target="$TARGET" "${COMPILER[@]}" \
    disable_path_overrides=no library_type=shared_library linkflags=-Wl,--version-script=dora_bridge.map \
    x11=no wayland=no vulkan=no opengl3=yes alsa=no pulseaudio=no speechd=no dbus=no \
    optimize="$OPTIMIZE" debug_symbols=no use_lto=no -j"${JOBS:-3}" > "$BUILD/build.log" 2>&1
printf 'Runtime: %s\n' "$SOURCE/bin/"libgodot*.so

LIBRARY="$(find "$SOURCE/bin" -maxdepth 1 -type f -name "libgodot.*.${TARGET}.*.so" -print -quit)"
[[ -n "$LIBRARY" ]] || { echo "Missing $TARGET runtime library" >&2; exit 1; }
python3 "$ROOT/Tools/Godot/package_runtime.py" --source "$SOURCE" --library "$LIBRARY" \
    --output "$BUILD/package" --architecture "$PACKAGE_ARCH"
