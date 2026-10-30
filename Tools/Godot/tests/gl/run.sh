#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
OUT="${DORA_GODOT_GL_TEST_OUTPUT:-$ROOT/build/godot-runtime/gl-transport}"
mkdir -p "$OUT"
rm -f "$OUT/verification.json"
"${CXX:-c++}" -std=c++20 -O0 -g -Wall -Wextra -Werror -I "$ROOT" \
    "$ROOT/Tools/Godot/tests/gl/transport.cpp" "$ROOT/Tools/Godot/module/gl/egl_transport.cpp" \
    -lEGL -lGLESv2 -o "$OUT/transport"
"$OUT/transport" | tee "$OUT/run.log"
python3 - "$OUT" <<'PY'
import json, platform, re, sys
from pathlib import Path
out=Path(sys.argv[1]); log=(out/'run.log').read_text()
assert 'EGL_TRANSPORT PASS consumers=3600 sampled_frames=99' in log
renderer=re.search(r'renderer=(.*?) version=(.*)',log)
report={'passed':True,'scope':'shared EGL transport on two independent contexts; Godot/Dora node not yet tested',
    'system':platform.system(),'machine':platform.machine(),'renderer':renderer[1],'gl_version':renderer[2],
    'consumer_frames':3600,'sampled_frames':99,'buffers':[2,3,4],'cpu_pixel_transport':False}
(out/'verification.json').write_text(json.dumps(report,indent=2)+'\n'); print(json.dumps(report,indent=2))
PY
