#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROBE="$ROOT/build/godot-metal-probe"
RESULTS="${DORA_GODOT_PROBE_OUTPUT:-$PROBE/results}"
SOURCE="$PROBE/deps/godot-4.6-stable"
ARCHIVE="$PROBE/deps/godot-4.6-stable.tar.gz"
[[ "$(uname -s)" == Darwin && "$(uname -m)" == arm64 ]] || { echo 'This prototype requires Apple Silicon macOS.' >&2; exit 1; }
mkdir -p "$PROBE/deps" "$RESULTS"
rm -f "$RESULTS/verification.json"
if [[ ! -f "$ARCHIVE" ]]; then
    curl -fL --retry 2 https://codeload.github.com/godotengine/godot/tar.gz/refs/tags/4.6-stable -o "$ARCHIVE"
fi
printf '%s  %s\n' b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0 "$ARCHIVE" | shasum -a 256 -c -
if [[ ! -d "$SOURCE" ]]; then tar -xzf "$ARCHIVE" -C "$PROBE/deps"; fi
if [[ ! -x "$PROBE/venv/bin/scons" ]]; then
    python3 -m venv "$PROBE/venv"
    "$PROBE/venv/bin/pip" install scons==4.11.1
fi
python3 "$ROOT/Tools/LibGodotMetalProbe/prepare_godot.py" "$SOURCE"
(
    cd "$SOURCE"
    "$PROBE/venv/bin/scons" platform=macos arch=arm64 target=template_debug \
        library_type=shared_library linkflags=-Wl,-exported_symbols_list,dora_metal_probe.exports disable_path_overrides=no vulkan=no opengl3=no metal=yes \
        modules_enabled_by_default=no module_dora_metal_probe_enabled=yes \
        module_freetype_enabled=yes module_text_server_fb_enabled=yes \
        module_gdscript_enabled=yes module_glslang_enabled=yes optimize=none debug_symbols=no use_lto=no -j"${JOBS:-5}"
) > "$PROBE/godot-build.log" 2>&1
cd "$ROOT"
DORA_BUILD_LIBGODOT_METAL_PROBE=1 xmake build -j"${JOBS:-4}" Dora > "$PROBE/dora-build.log" 2>&1
APP="$PROBE/dora/Dora.app"
# Only the generated prototype bundle is changed; the repository Assets remain intact.
printf 'return true\n' > "$APP/Contents/Resources/Script/init.lua"
codesign --force --deep --sign - "$APP" > "$PROBE/codesign.log" 2>&1
if [[ "${1:-}" == --build-only ]]; then exit 0; fi
mkdir -p "$ROOT/Tools/LibGodotMetalProbe/project/.godot"
printf 'list=[]\n' > "$ROOT/Tools/LibGodotMetalProbe/project/.godot/global_script_class_cache.cfg"
export DORA_LIBGODOT_METAL_PROBE=1
export DORA_GODOT_PROBE_LIBRARY="$SOURCE/bin/libgodot.macos.template_debug.arm64.dylib"
export DORA_GODOT_PROBE_PROJECT="$ROOT/Tools/LibGodotMetalProbe/project"
export DORA_GODOT_PROBE_OUTPUT="$RESULTS"
export GODOT_SILENCE_ROOT_WARNING=1
python3 - "$APP/Contents/MacOS/Dora" "$RESULTS/run.log" <<'PYRUN'
import os, subprocess, sys
limit = int(os.environ.get('DORA_GODOT_PROBE_FRAMES', '1800'))
timeout = None if os.environ.get('DORA_GODOT_PROBE_KEEP_OPEN') else max(120, limit / 15 + 60)
with open(sys.argv[2], 'w') as log:
    try:
        result = subprocess.run([sys.argv[1]], stdout=log, stderr=subprocess.STDOUT, timeout=timeout)
    except subprocess.TimeoutExpired:
        sys.exit('Prototype timed out; possible GPU synchronization deadlock. Inspect ' + sys.argv[2])
sys.exit(result.returncode)
PYRUN

if grep -Eq 'ERROR:|GODOT_METAL_PROBE FAIL|BGFX LEAK:' "$RESULTS/run.log"; then
    echo "Prototype reported errors; inspect $RESULTS/run.log" >&2
    exit 1
fi
