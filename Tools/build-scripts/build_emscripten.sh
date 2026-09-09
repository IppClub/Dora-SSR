#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_DIR="$ROOT_DIR/Projects/Emscripten"
BUILD_DIR="${DORA_EMSCRIPTEN_BUILD_DIR:-$ROOT_DIR/result/emscripten}"
PACKAGE_DIR="${DORA_EMSCRIPTEN_PACKAGE_DIR:-$ROOT_DIR/result/dora-ssr-web}"
WEB_IDE_DIR="${DORA_EMSCRIPTEN_WEB_IDE_DIR:-$ROOT_DIR/Assets/www/dora-ssr-web}"
RUST_MANIFEST="$ROOT_DIR/Source/Rust/Cargo.toml"
RUST_TARGET="wasm32-unknown-emscripten"
RUST_RUNTIME="$ROOT_DIR/Source/Rust/target/$RUST_TARGET/release/libdora_runtime.a"

if ! mkdir -p "$BUILD_DIR" 2>/dev/null; then
	# Some packaged checkouts expose result/ as a read-only symlink. Keep the
	# documented location as the default, but provide a writable local fallback.
	BUILD_DIR="${DORA_EMSCRIPTEN_BUILD_DIR:-$ROOT_DIR/build/emscripten}"
	mkdir -p "$BUILD_DIR"
	echo "[WARN] result/ is not writable; using $BUILD_DIR"
fi

if ! mkdir -p "$PACKAGE_DIR" 2>/dev/null; then
	PACKAGE_DIR="$BUILD_DIR/dora-ssr-web"
	mkdir -p "$PACKAGE_DIR"
	echo "[WARN] result/ package directory is not writable; using $PACKAGE_DIR"
fi

for tool in emcc emcmake emmake; do
	if ! command -v "$tool" >/dev/null 2>&1; then
		echo "[ERROR] Required Emscripten tool not found: $tool" >&2
		exit 1
	fi
done

build_rust_runtime() {
	local cargo_args=(
		build
		--manifest-path "$RUST_MANIFEST"
		--target "$RUST_TARGET"
		--release
	)

	if command -v cargo >/dev/null 2>&1; then
		RUSTC_WRAPPER= TMPDIR="${TMPDIR:-/tmp}" cargo "${cargo_args[@]}"
	elif command -v rustup >/dev/null 2>&1; then
		RUSTC_WRAPPER= TMPDIR="${TMPDIR:-/tmp}" rustup run stable cargo "${cargo_args[@]}"
	elif [[ -n "${RUST_TOOLCHAIN_BIN:-}" && -x "${RUST_TOOLCHAIN_BIN}/cargo" ]]; then
		PATH="$RUST_TOOLCHAIN_BIN:$PATH" RUSTC_WRAPPER= TMPDIR="${TMPDIR:-/tmp}" cargo "${cargo_args[@]}"
	elif [[ -x "$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo" ]]; then
		local user_rust_bin="$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin"
		PATH="$user_rust_bin:$PATH" RUSTC_WRAPPER= TMPDIR="${TMPDIR:-/tmp}" cargo "${cargo_args[@]}"
	elif command -v nix-shell >/dev/null 2>&1; then
		# The repository's Nix environment provides rustup but not cargo directly.
		nix-shell -p rustup --run \
			"RUSTC_WRAPPER= TMPDIR=/tmp rustup run stable cargo build --manifest-path '$RUST_MANIFEST' --target '$RUST_TARGET' --release"
	else
		echo "[ERROR] Rust toolchain not found (cargo, rustup, or nix-shell required)" >&2
		exit 1
	fi

	if [[ ! -f "$RUST_RUNTIME" ]]; then
		echo "[ERROR] Rust build completed without producing $RUST_RUNTIME" >&2
		exit 1
	fi
}

build_rust_runtime

# LuaBinding.cpp is generated and intentionally ignored by git. Generate it
# before configuring CMake so a clean checkout uses the current Lua API.
"$ROOT_DIR/Tools/tolua++/build.sh"

cp "$SOURCE_DIR/shell.html" "$BUILD_DIR/shell.html"
bash "$SCRIPT_DIR/build_wa_web.sh" "$BUILD_DIR/wa-web"

emcmake cmake \
	-S "$SOURCE_DIR" \
	-B "$BUILD_DIR" \
	-DCMAKE_BUILD_TYPE=Release \
	-DDORA_EMSCRIPTEN_SHELL="$BUILD_DIR/shell.html" \
	-DDORA_RUST_RUNTIME="$RUST_RUNTIME"

emmake make -C "$BUILD_DIR" -j"${JOBS:-2}"

for artifact in dora-ssr.html dora-ssr.js dora-ssr.wasm dora-ssr.data; do
	if [[ ! -f "$BUILD_DIR/$artifact" ]]; then
		echo "[ERROR] Missing Emscripten artifact: $BUILD_DIR/$artifact" >&2
		exit 1
	fi
	cp "$BUILD_DIR/$artifact" "$PACKAGE_DIR/$artifact"
done
cp "$BUILD_DIR/dora-ssr.html" "$PACKAGE_DIR/index.html"
if [[ -f "$BUILD_DIR/dora-ssr.worker.js" ]]; then
	cp "$BUILD_DIR/dora-ssr.worker.js" "$PACKAGE_DIR/dora-ssr.worker.js"
fi
cp "$BUILD_DIR/wa-web/dora-wa.wasm" "$PACKAGE_DIR/dora-wa.wasm"
install -m 0644 "$BUILD_DIR/wa-web/wasm_exec.js" "$PACKAGE_DIR/wasm_exec.js"

# Keep a hostable copy under the existing Web IDE static root. Assets/www is
# excluded from the engine preload above, so this deployment copy never feeds
# back into dora-ssr.data on a later build.
mkdir -p "$WEB_IDE_DIR"
for artifact in index.html dora-ssr.html dora-ssr.js dora-ssr.wasm dora-ssr.data dora-wa.wasm wasm_exec.js; do
	install -m 0644 "$PACKAGE_DIR/$artifact" "$WEB_IDE_DIR/$artifact"
done

echo "[INFO] Emscripten output: $BUILD_DIR/dora-ssr.html"
echo "[INFO] Web package: $PACKAGE_DIR"
echo "[INFO] Web IDE package: $WEB_IDE_DIR"
