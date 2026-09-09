#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/Projects/Web/toolchain.env"

ALLOW_DRIFT="${DORA_WEB_ALLOW_TOOLCHAIN_DRIFT:-0}"

require_tool() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "[ERROR] Required Web build tool is missing: $1" >&2
		exit 1
	fi
}

check_version() {
	local tool="$1"
	local actual="$2"
	local expected="$3"
	if [[ "$actual" == "$expected" || "$actual" == "$expected".* ]]; then
		echo "[OK] $tool $actual"
	elif [[ "$ALLOW_DRIFT" == "1" ]]; then
		echo "[WARN] $tool version drift: expected $expected, found $actual" >&2
	else
		echo "[ERROR] $tool version drift: expected $expected, found $actual" >&2
		echo "        Set DORA_WEB_ALLOW_TOOLCHAIN_DRIFT=1 only for local diagnosis." >&2
		exit 1
	fi
}

for tool in emcc emcmake emmake rustup cargo go node cmake; do
	require_tool "$tool"
done

EMSCRIPTEN_ACTUAL="$(emcc --version | sed -n '1s/.*emcc ([^)]*) \([0-9][0-9.]*\).*/\1/p')"
RUST_ACTUAL="$(rustc --version | awk '{print $2}')"
GO_ACTUAL="$(go version | sed -n 's/.* go\([0-9][0-9.]*\) .*/\1/p')"
NODE_ACTUAL="$(node --version | sed 's/^v//')"
CMAKE_ACTUAL="$(cmake --version | awk 'NR == 1 {print $3}')"

check_version Emscripten "$EMSCRIPTEN_ACTUAL" "$DORA_WEB_EMSCRIPTEN_VERSION"
check_version Rust "$RUST_ACTUAL" "$DORA_WEB_RUST_VERSION"
check_version Go "$GO_ACTUAL" "$DORA_WEB_GO_VERSION"
check_version Node "$NODE_ACTUAL" "$DORA_WEB_NODE_VERSION"
check_version CMake "$CMAKE_ACTUAL" "$DORA_WEB_CMAKE_VERSION"

if ! rustup target list --installed | grep -qx "$DORA_WEB_RUST_TARGET"; then
	echo "[ERROR] Rust target is missing: $DORA_WEB_RUST_TARGET" >&2
	echo "        Install it with: rustup target add $DORA_WEB_RUST_TARGET" >&2
	exit 1
fi
