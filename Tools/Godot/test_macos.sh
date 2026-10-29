#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$ROOT/build/godot-runtime"
TARGET="${DORA_GODOT_TARGET:-template_debug}"
case "$TARGET" in template_debug|template_release) ;; *) printf 'Unsupported DORA_GODOT_TARGET\n' >&2; exit 2 ;; esac
RESULTS="${DORA_GODOT_NODE_RESULTS:-$BUILD/node-results}"
mkdir -p "$RESULTS"
rm -f "$RESULTS/verification.json"
"$ROOT/Tools/Godot/build_runtime.sh" > "$BUILD/runtime-launcher.log" 2>&1
cd "$ROOT"
DORA_BUILD_GODOT_NODE_TEST=1 xmake build -j"${JOBS:-3}" Dora > "$BUILD/node-test-build.log" 2>&1
APP="$BUILD/dora/Dora.app"
printf 'return true\n' > "$APP/Contents/Resources/Script/init.lua"
codesign --force --deep --sign - "$APP" > "$BUILD/node-test-codesign.log" 2>&1
for FIXTURE in project timing_project; do
    mkdir -p "$ROOT/Tools/Godot/tests/$FIXTURE/.godot"
    printf 'list=[]\n' > "$ROOT/Tools/Godot/tests/$FIXTURE/.godot/global_script_class_cache.cfg"
done
export DORA_GODOT_LIBRARY="$BUILD/deps/godot-4.6-stable/bin/libgodot.macos.$TARGET.arm64.dylib"
export DORA_GODOT_TEST_PROJECT="${DORA_GODOT_TEST_PROJECT:-$ROOT/Tools/Godot/tests/project}"
export DORA_GODOT_TEST_OUTPUT="$RESULTS"
ABI=(python3 "$ROOT/Tools/Godot/tests/runtime_abi.py" --library "$DORA_GODOT_LIBRARY" --backend Metal --output "$RESULTS/abi-preboot")
if [[ "${DORA_GODOT_TEST_AUDIO:-}" == 1 ]]; then ABI+=(--require-audio); fi
"${ABI[@]}"
export MTL_DEBUG_LAYER=1
python3 - "$APP/Contents/MacOS/Dora" "$RESULTS/run.log" <<'PYRUN'
import subprocess, sys
with open(sys.argv[2],'w') as log:
    result=subprocess.run([sys.argv[1]],stdout=log,stderr=subprocess.STDOUT,timeout=180+int(__import__("os").environ.get("DORA_GODOT_TEST_SOAK_FRAMES","0"))/30)
sys.exit(result.returncode)
PYRUN
if [[ "${DORA_GODOT_TEST_TIMING:-}" == 1 ]]; then
    python3 "$ROOT/Tools/Godot/tests/verify_timing.py" --results "$RESULTS" --platform 'macOS Metal'
    exit 0
fi
VERIFY=(python3 "$ROOT/Tools/Godot/tests/verify_macos.py" --results "$RESULTS")
VERIFY+=(--soak-frames "${DORA_GODOT_TEST_SOAK_FRAMES:-0}")
if [[ "${DORA_GODOT_TEST_RESIZE:-}" == 1 ]]; then VERIFY+=(--resize); fi
if [[ "${DORA_GODOT_TEST_CANCEL_RESIZE:-}" == 1 ]]; then VERIFY+=(--cancel-resize); fi
if [[ "${DORA_GODOT_TEST_RESERVATION:-}" == 1 ]]; then VERIFY+=(--reservation); fi
VERIFY+=(--buffers "${DORA_GODOT_TEST_BUFFERS:-3}")
if [[ -n "${DORA_GODOT_FIXTURE_MANIFEST:-}" ]]; then VERIFY+=(--fixture "$DORA_GODOT_FIXTURE_MANIFEST"); fi
if [[ "${DORA_GODOT_TEST_AUDIO:-}" == 1 ]]; then VERIFY+=(--audio); fi
if [[ "${DORA_GODOT_TEST_AUDIO_STALL:-}" == 1 ]]; then VERIFY+=(--audio-stall); fi
if [[ "${DORA_GODOT_TEST_ALIASES:-}" == 1 ]]; then VERIFY+=(--aliases); fi
if [[ "${DORA_GODOT_TEST_CONTROLLER:-}" == 1 ]]; then VERIFY+=(--controller); fi
"${VERIFY[@]}"
