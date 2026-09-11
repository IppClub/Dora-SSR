#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
node "$SCRIPT_DIR/check_web_api_parity.mjs"
SOURCE_DIR="$ROOT_DIR/Projects/Web"
BUILD_DIR="${DORA_WEB_BUILD_DIR:-$ROOT_DIR/build/web}"
PACKAGE_DIR="${DORA_WEB_PACKAGE_DIR:-$ROOT_DIR/result/dora-web-build-probe}"
PLAYER_PACKAGE_DIR="${DORA_WEB_PLAYER_PACKAGE_DIR:-$ROOT_DIR/result/dora-web-player}"
LOVE_PLAYER_PACKAGE_DIR="${DORA_WEB_LOVE_PLAYER_PACKAGE_DIR:-$ROOT_DIR/result/love-pthread-player}"
BUILD_ENGINE="${DORA_WEB_BUILD_ENGINE:-1}"
LINK_PLAYER="${DORA_WEB_LINK_PLAYER:-$BUILD_ENGINE}"
BUILD_LOVE_PROBE="${DORA_WEB_BUILD_LOVE_PROBE:-$BUILD_ENGINE}"
BUILD_PTHREADS="${DORA_WEB_PTHREADS:-0}"
BUILD_LOVE_PLAYER="${DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER:-$BUILD_PTHREADS}"
WEB_PROFILE="${DORA_WEB_PROFILE:-dora-preset}"
if [[ "$BUILD_PTHREADS" == "1" && -z "${DORA_WEB_PLAYER_PACKAGE_DIR+x}" ]]; then
	PLAYER_PACKAGE_DIR="$ROOT_DIR/result/dora-web-player-pthreads"
fi
# shellcheck source=/dev/null
source "$ROOT_DIR/Projects/Web/toolchain.env"
RUST_RUNTIME="$ROOT_DIR/Source/Rust/target/$DORA_WEB_RUST_TARGET/release/libdora_runtime.a"
RUST_USER_ROOT="$(dirname "$(rustup show home)")"
RUST_TOOLCHAIN_ROOT="$(rustc --print sysroot)"
RUST_REMAP_FLAGS="--remap-path-prefix=$RUST_USER_ROOT=/build-user --remap-path-prefix=$RUST_TOOLCHAIN_ROOT=/rust-toolchain"

"$SCRIPT_DIR/check_web_build_env.sh"
RUSTC_WRAPPER='' RUSTFLAGS="$RUST_REMAP_FLAGS ${RUSTFLAGS:-}" cargo build \
	--manifest-path "$ROOT_DIR/Source/Rust/Cargo.toml" \
	--target "$DORA_WEB_RUST_TARGET" \
	--locked \
	--release
if [[ ! -s "$RUST_RUNTIME" ]]; then
	echo "[ERROR] Rust Web runtime was not produced: $RUST_RUNTIME" >&2
	exit 1
fi

CMAKE_ARGS=(
	-S "$SOURCE_DIR"
	-B "$BUILD_DIR"
	-DCMAKE_BUILD_TYPE=Release
	-DDORA_RUST_RUNTIME="$RUST_RUNTIME"
	-DDORA_WEB_BUILD_ENGINE="$BUILD_ENGINE"
	-DDORA_WEB_BUILD_LOVE_PROBE="$BUILD_LOVE_PROBE"
	-DDORA_WEB_BUILD_LOVE_PTHREAD_PLAYER="$BUILD_LOVE_PLAYER"
	-DDORA_WEB_LINK_PLAYER="$LINK_PLAYER"
	-DDORA_WEB_PTHREADS="$BUILD_PTHREADS"
	-DDORA_WEB_PROFILE="$WEB_PROFILE"
)
for feature in PHYSICS_2D ENTITY PLATFORMER BUILTIN_LIBS ML YUE MODEL_3D; do
	value_var="DORA_WEB_FEATURE_${feature}"
	if [[ -n "${!value_var+x}" ]]; then
		CMAKE_ARGS+=("-D${value_var}=${!value_var}")
	fi
done
if [[ -n "${DORA_WEB_BUILTIN_FONT:-}" ]]; then
	CMAKE_ARGS+=("-DDORA_WEB_BUILTIN_FONT=$DORA_WEB_BUILTIN_FONT")
fi
if [[ -n "${DORA_WEB_LOVE_COMPLEX_PACKAGE:-}" ]]; then
	CMAKE_ARGS+=("-DDORA_WEB_LOVE_COMPLEX_PACKAGE=$DORA_WEB_LOVE_COMPLEX_PACKAGE")
fi
emcmake cmake "${CMAKE_ARGS[@]}"

BUILD_TARGETS=(dora-web-build-probe)
if [[ "$BUILD_ENGINE" == "1" ]]; then
	BUILD_TARGETS+=(dora-web-engine)
fi
if [[ "$BUILD_LOVE_PROBE" == "1" ]]; then
	BUILD_TARGETS+=(dora-web-love-support dora-web-love-compile-probe dora-web-love-node-compile-probe)
fi
if [[ "$BUILD_LOVE_PROBE" == "1" && "$LINK_PLAYER" == "1" ]]; then
	BUILD_TARGETS+=(dora-web-love-link-probe dora-web-love-graphics-probe dora-web-love-shader-probe dora-web-love-audio-probe)
	if [[ -n "${DORA_WEB_LOVE_COMPLEX_PACKAGE:-}" ]]; then
		BUILD_TARGETS+=(dora-web-love-complex-probe)
	fi
fi
if [[ "$BUILD_LOVE_PLAYER" == "1" ]]; then
	BUILD_TARGETS+=(dora-web-love-pthread-player)
fi
if [[ "$LINK_PLAYER" == "1" ]]; then
	BUILD_TARGETS+=(dora-web-player)
fi

cmake --build "$BUILD_DIR" --target "${BUILD_TARGETS[@]}" --parallel "${JOBS:-2}"

cmake -E remove_directory "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"
for artifact in dora-player.html dora-player.js dora-player.wasm; do
	if [[ ! -s "$BUILD_DIR/$artifact" ]]; then
		echo "[ERROR] Missing Web build artifact: $BUILD_DIR/$artifact" >&2
		exit 1
	fi
	install -m 0644 "$BUILD_DIR/$artifact" "$PACKAGE_DIR/$artifact"
done
install -m 0644 "$BUILD_DIR/dora-player.html" "$PACKAGE_DIR/index.html"

echo "[INFO] Web build probe: $PACKAGE_DIR"

if [[ "$BUILD_LOVE_PLAYER" == "1" ]]; then
	cmake -E remove_directory "$LOVE_PLAYER_PACKAGE_DIR"
	mkdir -p "$LOVE_PLAYER_PACKAGE_DIR"
	for artifact in love-pthread-player.html love-pthread-player.js love-pthread-player.wasm love-pthread-player.data; do
		if [[ ! -s "$BUILD_DIR/$artifact" ]]; then
			echo "[ERROR] Missing Love pthread Player artifact: $BUILD_DIR/$artifact" >&2
			exit 1
		fi
		install -m 0644 "$BUILD_DIR/$artifact" "$LOVE_PLAYER_PACKAGE_DIR/$artifact"
	done
	install -m 0644 "$BUILD_DIR/love-pthread-player.html" "$LOVE_PLAYER_PACKAGE_DIR/index.html"
	if [[ -s "$BUILD_DIR/love-pthread-player.worker.js" ]]; then
		install -m 0644 "$BUILD_DIR/love-pthread-player.worker.js" "$LOVE_PLAYER_PACKAGE_DIR/love-pthread-player.worker.js"
	fi
	echo "[INFO] Love pthread Player: $LOVE_PLAYER_PACKAGE_DIR"
fi

if [[ "$LINK_PLAYER" == "1" ]]; then
	cmake -E remove_directory "$PLAYER_PACKAGE_DIR"
	mkdir -p "$PLAYER_PACKAGE_DIR"
	for artifact in dora-player-runtime.html dora-player-runtime.js dora-player-runtime.wasm dora-player-runtime.data dora-web-manifest.json dora-web-features.json; do
		if [[ ! -s "$BUILD_DIR/$artifact" ]]; then
			echo "[ERROR] Missing Web Player artifact: $BUILD_DIR/$artifact" >&2
			exit 1
		fi
		install -m 0644 "$BUILD_DIR/$artifact" "$PLAYER_PACKAGE_DIR/$artifact"
	done
	cmake -E copy_directory "$BUILD_DIR/assets" "$PLAYER_PACKAGE_DIR/assets"
	install -m 0644 "$BUILD_DIR/dora-player-runtime.html" "$PLAYER_PACKAGE_DIR/index.html"
	if [[ -s "$BUILD_DIR/dora-player-runtime.worker.js" ]]; then
		install -m 0644 "$BUILD_DIR/dora-player-runtime.worker.js" "$PLAYER_PACKAGE_DIR/dora-player-runtime.worker.js"
	fi
	echo "[INFO] Dora Web Player: $PLAYER_PACKAGE_DIR"
fi
