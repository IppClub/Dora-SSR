#!/bin/bash
# Repeat the real GPU tests against the current host/bgfx sources.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BASE="${DORA_GODOT_MATRIX_OUTPUT:-$ROOT/build/godot-metal-probe/current-matrix}"
mkdir -p "$BASE"
rm -f "$BASE/verification.json"
for entry in '3 1800 0 1 animation' '2 1200 1000000 1 pressure' '4 600 1000000 1 four-buffer'; do
    read -r buffers frames work unlimited name <<< "$entry"
    output="$BASE/$name"
    MTL_DEBUG_LAYER=1 DORA_GODOT_PROBE_BUFFERS="$buffers" \
        DORA_GODOT_PROBE_FRAMES="$frames" DORA_GODOT_PROBE_GPU_WORK="$work" \
        DORA_GODOT_PROBE_UNLIMITED="$unlimited" DORA_GODOT_PROBE_OUTPUT="$output" \
        "$ROOT/Tools/LibGodotMetalProbe/run.sh"
    python3 "$ROOT/Tools/LibGodotMetalProbe/verify_outputs.py" "$output"
done
python3 - "$BASE" <<'PY'
import json, pathlib, sys
root = pathlib.Path(sys.argv[1])
reports = {name: json.loads((root/name/'verification.json').read_text())
           for name in ('animation', 'pressure', 'four-buffer')}
for name in reports:
    assert 'Metal API Validation Enabled' in (root/name/'run.log').read_text()
assert reports['pressure']['gpu_accounting']['deferred_productions'] > 0
result = {'passed': True, 'platform': 'macOS Metal', 'metal_api_validation': True,
          'consumer_frames': sum(r['gpu_accounting']['consumer_completed'] for r in reports.values()),
          'cases': reports}
(root/'verification.json').write_text(json.dumps(result, indent=2)+'\n')
print('Current-source Metal matrix: PASS; consumer frames:', result['consumer_frames'])
PY
