#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
OUT="${DORA_GODOT_PROTOCOL_OUTPUT:-$ROOT/build/godot-runtime/protocol}"
mkdir -p "$OUT"
rm -f "$OUT/verification.json" "$OUT/embedded-shader.json"
cd "$ROOT"
"${CC:-cc}" -std=c11 -Wall -Wextra -Werror -I . Tools/Godot/tests/bridge_abi.c -o "$OUT/abi-c"
"$OUT/abi-c"
"${CXX:-c++}" -std=c++20 -Wall -Wextra -Werror -I . Tools/Godot/tests/frame_ring.cpp -o "$OUT/frame-ring"
"${CXX:-c++}" -std=c++20 -Wall -Wextra -Werror -I . Tools/Godot/tests/render_boot.cpp -o "$OUT/render-boot"
"${CXX:-c++}" -std=c++20 -Wall -Wextra -Werror -I . Tools/Godot/tests/render_timing.cpp -o "$OUT/render-timing"
"$OUT/render-timing"
"$OUT/render-boot"
"$OUT/frame-ring"
"${CXX:-c++}" -std=c++20 -pthread -Wall -Wextra -Werror -I . Tools/Godot/tests/audio_queue.cpp -o "$OUT/audio-queue"
"$OUT/audio-queue"
"${CXX:-c++}" -std=c++20 -Wall -Wextra -Werror -I . Tools/Godot/tests/gpu_reads.cpp -o "$OUT/gpu-reads"
"$OUT/gpu-reads"
python3 Tools/Godot/tests/embedded_shader.py --output "$OUT"
python3 Tools/Godot/tests/web/task_queue_stop.py --output "$OUT/web-task-queue"
python3 - "$OUT" <<'PYREPORT'
import json, platform, sys
from pathlib import Path
report={'passed': True, 'scope':'C ABI declaration and backend-independent frame ownership protocol; GPU not tested',
        'system': platform.system(), 'machine': platform.machine(), 'buffers':[2,3,4], 'consumer_frames_per_buffer':100000,'texture_boot_frame_gate':True,'manual_render_time_handoff':True,
        'audio_spsc_stereo_frames':300000,'audio_device_tested':False,'all_slot_gpu_reader_ledger_host_frames':300000,
        'fresh_embedded_shader_source_boundary':True,'web_task_queue_final_stop':True}
(Path(sys.argv[1])/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
PYREPORT
