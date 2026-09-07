#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
WA_SOURCE_DIR="$ROOT_DIR/Source/3rdParty/Wa/Source"
OUTPUT_DIR="${1:-$ROOT_DIR/result/dora-wa-web}"

if ! command -v go >/dev/null 2>&1; then
	echo "[ERROR] Go toolchain is required to build the browser Wa module" >&2
	exit 1
fi

if [[ ! -f "$WA_SOURCE_DIR/wa.gomobile" || ! -f "$WA_SOURCE_DIR/web/main.go" ]]; then
	echo "[ERROR] Wa browser sources are incomplete" >&2
	exit 1
fi

mkdir -p "$OUTPUT_DIR"
STAGE_DIR="$(mktemp -d /tmp/dora-wa-web.XXXXXX)"
cp -R "$WA_SOURCE_DIR/." "$STAGE_DIR/"
mv "$STAGE_DIR/wa.gomobile" "$STAGE_DIR/wa.go"
mv "$STAGE_DIR/main.go" "$STAGE_DIR/main.go.native"

GO_CACHE_DIR="${DORA_WA_GOCACHE:-/tmp/dora-wa-gocache}"
mkdir -p "$GO_CACHE_DIR"
(
	cd "$STAGE_DIR"
	GOOS=js GOARCH=wasm CGO_ENABLED=0 \
		GOCACHE="$GO_CACHE_DIR" GOFLAGS=-mod=mod \
		go build -buildvcs=false -trimpath -ldflags="-s -w" -o "$OUTPUT_DIR/dora-wa.wasm" ./web
)

GO_ROOT="$(go env GOROOT)"
WASM_EXEC="$GO_ROOT/lib/wasm/wasm_exec.js"
if [[ ! -f "$WASM_EXEC" ]]; then
	WASM_EXEC="$GO_ROOT/misc/wasm/wasm_exec.js"
fi
if [[ ! -f "$WASM_EXEC" ]]; then
	echo "[ERROR] Go wasm_exec.js was not found below $GO_ROOT" >&2
	exit 1
fi
install -m 0644 "$WASM_EXEC" "$OUTPUT_DIR/wasm_exec.js"

echo "[INFO] Browser Wa module: $OUTPUT_DIR/dora-wa.wasm"
