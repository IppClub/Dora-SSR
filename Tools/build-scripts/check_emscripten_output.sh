#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${1:-${DORA_EMSCRIPTEN_PACKAGE_DIR:-$ROOT_DIR/result/dora-ssr-web}}"

if [[ ! -d "$OUTPUT_DIR" ]]; then
	if [[ -d "$ROOT_DIR/build/emscripten/dora-ssr-web" ]]; then
		OUTPUT_DIR="$ROOT_DIR/build/emscripten/dora-ssr-web"
	else
		echo "[ERROR] Emscripten package directory not found: $OUTPUT_DIR" >&2
		exit 1
	fi
fi

for artifact in index.html dora-ssr.html dora-ssr.js dora-ssr.wasm dora-ssr.data; do
	if [[ ! -s "$OUTPUT_DIR/$artifact" ]]; then
		echo "[ERROR] Missing or empty artifact: $OUTPUT_DIR/$artifact" >&2
		exit 1
	fi
done
for artifact in dora-wa.wasm wasm_exec.js; do
	if [[ ! -s "$OUTPUT_DIR/$artifact" ]]; then
		echo "[ERROR] Missing browser Wa artifact: $OUTPUT_DIR/$artifact" >&2
		exit 1
	fi
done

node --check "$OUTPUT_DIR/dora-ssr.js"
node --check "$OUTPUT_DIR/wasm_exec.js"
node "$SCRIPT_DIR/check_wa_web.mjs" "$OUTPUT_DIR"
# Keep the checks quiet on success, but identify the exact generated-artifact
# assertion when a toolchain changes its output layout.
trap 'echo "[ERROR] verification command failed: ${BASH_COMMAND}" >&2' ERR
grep -q '<script' "$OUTPUT_DIR/index.html"
grep -q 'dora-ssr.js' "$OUTPUT_DIR/index.html"
grep -q 'DoraWeb' "$OUTPUT_DIR/index.html"
grep -q 'pickProject' "$OUTPUT_DIR/index.html"
grep -q 'showDirectoryPicker' "$OUTPUT_DIR/index.html"
grep -q 'startSharedPackage' "$OUTPUT_DIR/index.html"
grep -q 'FS.syncfs' "$OUTPUT_DIR/index.html"
grep -q "addRunDependency('dora-idbfs')" "$OUTPUT_DIR/index.html"
grep -q 'persistentFileSystemReady' "$OUTPUT_DIR/index.html"
grep -q 'project root must contain init.lua' "$OUTPUT_DIR/index.html"
grep -q 'resumeAudio' "$OUTPUT_DIR/index.html"
grep -q 'App.platform == "Emscripten"' "$OUTPUT_DIR/dora-ssr.data"
grep -q 'dora_web_run_project' "$OUTPUT_DIR/dora-ssr.js"
grep -q 'dora_web_stop_project' "$OUTPUT_DIR/dora-ssr.js"
grep -q 'dora_web_file_dialog_result' "$OUTPUT_DIR/dora-ssr.js"
grep -q 'Script/Dev/WebRunner' "$OUTPUT_DIR/dora-ssr.js"
grep -q 'Script/Dev/WebProjects' "$OUTPUT_DIR/dora-ssr.js"
grep -q 'Dora.globals.webProjects' "$OUTPUT_DIR/dora-ssr.data"
if ! rg -a -q 'Dora\.Path' "$OUTPUT_DIR/dora-ssr.js" "$OUTPUT_DIR/dora-ssr.data"; then
	echo "[ERROR] WebRunner does not bind Dora.Path" >&2
	exit 1
fi

echo "[INFO] Emscripten package verified: $OUTPUT_DIR"
