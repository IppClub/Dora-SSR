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

echo "[INFO] Emscripten package verified: $OUTPUT_DIR"
