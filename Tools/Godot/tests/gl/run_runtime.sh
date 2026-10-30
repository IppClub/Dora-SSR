#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
OUT="${DORA_GODOT_GL_RUNTIME_OUTPUT:-$ROOT/build/godot-runtime/gl-runtime}"
LIB="${DORA_GODOT_LIBRARY:?Set DORA_GODOT_LIBRARY to the Linux bridge .so}"
mkdir -p "$OUT"
"${CXX:-c++}" -std=c++20 -O0 -g -Wall -Wextra -Werror -I "$ROOT" \
    "$ROOT/Tools/Godot/tests/gl/runtime.cpp" -lEGL -lGLESv2 -ldl -pthread -o "$OUT/runtime"
mkdir -p "$ROOT/Tools/Godot/tests/project/.godot"
printf 'list=[]\n' > "$ROOT/Tools/Godot/tests/project/.godot/global_script_class_cache.cfg"
"$OUT/runtime" "$LIB" "$ROOT/Tools/Godot/tests/project" "$OUT" > "$OUT/run.log" 2>&1
