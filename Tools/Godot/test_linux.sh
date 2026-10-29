#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$ROOT/build/godot-runtime"
RESULTS="${DORA_GODOT_NODE_RESULTS:-$BUILD/node-linux-results}"
mkdir -p "$RESULTS"
rm -f "$RESULTS/verification.json"
cd "$ROOT"
if [[ "${DORA_GODOT_SKIP_BUILD:-0}" != 1 ]]; then
    "$ROOT/Tools/Godot/build_linux_runtime.sh" > "$BUILD/linux-runtime-launcher.log" 2>&1
    DORA_BUILD_GODOT_NODE_TEST=1 xmake build -j"${JOBS:-3}" Dora > "$BUILD/node-linux-build.log" 2>&1
fi
LIBRARY="${DORA_GODOT_LIBRARY:-$ROOT/build/godot-linux/package/libdora_godot.so}"
DORA_BINARY="${DORA_GODOT_DORA_BINARY:-$BUILD/dora/Dora}"
[[ -f "$LIBRARY" ]] || { echo 'Godot runtime library missing' >&2; exit 1; }
[[ -x "$DORA_BINARY" ]] || { echo 'Dora test host missing or not executable' >&2; exit 1; }
# Stage assets for this test only. Never edit source Assets/Script/init.lua.
mkdir -p "$BUILD/test-assets"
rsync -a "$ROOT/Assets/" "$BUILD/test-assets/"
printf 'return true\n' > "$BUILD/test-assets/Script/init.lua"
for FIXTURE in project timing_project; do
    mkdir -p "$ROOT/Tools/Godot/tests/$FIXTURE/.godot"
    printf 'list=[]\n' > "$ROOT/Tools/Godot/tests/$FIXTURE/.godot/global_script_class_cache.cfg"
done
export DORA_GODOT_LIBRARY="$LIBRARY"
export DORA_GODOT_TEST_PROJECT="${DORA_GODOT_TEST_PROJECT:-$ROOT/Tools/Godot/tests/project}"
export DORA_GODOT_TEST_OUTPUT="$RESULTS"
ABI=(python3 "$ROOT/Tools/Godot/tests/runtime_abi.py" --library "$DORA_GODOT_LIBRARY" --backend EGL --output "$RESULTS/abi-preboot")
if [[ "${DORA_GODOT_TEST_AUDIO:-}" == 1 ]]; then ABI+=(--require-audio); fi
if [[ "${DORA_GODOT_SKIP_PREBOOT_ABI:-0}" == 1 ]]; then
    echo 'Skipping ctypes preboot ABI checks because the verifier process architecture differs from the runtime.'
else
    "${ABI[@]}"
fi
export SDL_AUDIODRIVER=dummy GODOT_SILENCE_ROOT_WARNING=1
python3 - "$DORA_BINARY" "$BUILD/test-assets" "$RESULTS/run.log" <<'PY'
import os, subprocess, sys
command=[sys.argv[1],'--asset',sys.argv[2]]
if not os.environ.get('DISPLAY') and not os.environ.get('WAYLAND_DISPLAY'):
    command=['xvfb-run','-a','-s','-screen 0 1920x1080x24']+command
with open(sys.argv[3],'w') as log:
    timeout=max(180+int(os.environ.get("DORA_GODOT_TEST_SOAK_FRAMES","0"))/30,
                120+int(os.environ.get('DORA_GODOT_TEST_CYCLES','0'))*10)
    result=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,timeout=timeout)
sys.exit(result.returncode)
PY
if [[ -n "${DORA_GODOT_TEST_CYCLES:-}" ]]; then
    python3 "$ROOT/Tools/Godot/tests/verify_cycles.py" --results "$RESULTS" --platform 'Linux EGL' \
        --cycles "$DORA_GODOT_TEST_CYCLES" --buffers "${DORA_GODOT_TEST_BUFFERS:-3}"
    exit 0
fi
if [[ "${DORA_GODOT_TEST_TIMING:-}" == 1 ]]; then
    python3 "$ROOT/Tools/Godot/tests/verify_timing.py" --results "$RESULTS" --platform 'Linux EGL'
    exit 0
fi
VERIFY=(python3 "$ROOT/Tools/Godot/tests/verify_macos.py" --platform 'Linux EGL' --results "$RESULTS")
VERIFY+=(--soak-frames "${DORA_GODOT_TEST_SOAK_FRAMES:-0}")
if [[ "${DORA_GODOT_TEST_RESERVATION:-}" == 1 ]]; then VERIFY+=(--reservation); fi
if [[ "${DORA_GODOT_TEST_RESIZE:-}" == 1 ]]; then VERIFY+=(--resize); fi
if [[ "${DORA_GODOT_TEST_CANCEL_RESIZE:-}" == 1 ]]; then VERIFY+=(--cancel-resize); fi
VERIFY+=(--buffers "${DORA_GODOT_TEST_BUFFERS:-3}")
if [[ -n "${DORA_GODOT_FIXTURE_MANIFEST:-}" ]]; then VERIFY+=(--fixture "$DORA_GODOT_FIXTURE_MANIFEST"); fi
if [[ "${DORA_GODOT_TEST_AUDIO:-}" == 1 ]]; then VERIFY+=(--audio); fi
if [[ "${DORA_GODOT_TEST_AUDIO_STALL:-}" == 1 ]]; then VERIFY+=(--audio-stall); fi
if [[ "${DORA_GODOT_TEST_ALIASES:-}" == 1 ]]; then VERIFY+=(--aliases); fi
if [[ "${DORA_GODOT_TEST_CONTROLLER:-}" == 1 ]]; then VERIFY+=(--controller); fi
"${VERIFY[@]}"
