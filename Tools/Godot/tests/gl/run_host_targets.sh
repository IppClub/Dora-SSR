#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
OUT="${DORA_GODOT_GL_TARGETS_OUTPUT:-$ROOT/build/godot-runtime/gl-host-targets}"
mkdir -p "$OUT"
rm -f "$OUT/verification.json"
"${CXX:-c++}" -std=c++20 -Wall -Wextra -Werror -I "$ROOT" \
 "$ROOT/Tools/Godot/tests/gl/host_targets.cpp" "$ROOT/Tools/Godot/module/gl/egl_transport.cpp" \
 -lEGL -lGLESv2 -o "$OUT/test"
"$OUT/test" | tee "$OUT/run.log"
python3 - "$OUT" <<'PY'
import json,sys
from pathlib import Path
p=Path(sys.argv[1]);log=(p/'run.log').read_text()
assert 'GL_TARGETS PASS buffers=2,3,4 generations=3 samples=54 host_ownership_preserved=1' in log
(p/'verification.json').write_text(json.dumps({'passed':True,'scope':'actual shared EGL transport; host ownership and immutable prior generations; Godot/Dora node checked separately','buffers':[2,3,4],'generations':3,'pixel_samples':54,'source_sizes':[64,96,32]},indent=2)+'\n')
PY
