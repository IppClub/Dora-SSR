#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MACHINE_ARCH="$(uname -m)"

case "$MACHINE_ARCH" in
	x86_64|amd64)
		BGFX_ARCH="x86_64"
		WA_ARCH="amd64"
		RUNTIME_ARCH="x86_64"
		RUST_TARGET="x86_64-unknown-linux-gnu"
		;;
	aarch64|arm64)
		BGFX_ARCH="arm64"
		WA_ARCH="aarch64"
		RUNTIME_ARCH="aarch64"
		RUST_TARGET="aarch64-unknown-linux-gnu"
		;;
	*)
		echo "Unsupported Linux architecture: $MACHINE_ARCH" >&2
		exit 1
		;;
esac

stop_running_dora() {
	if pgrep -x dora-ssr >/dev/null; then
		pkill -x dora-ssr
		while pgrep -x dora-ssr >/dev/null; do
			sleep 0.2
		done
	fi
}

prepare_display_env() {
	local xwayland_args
	local xauth

	if [ -z "${XDG_RUNTIME_DIR:-}" ] && [ -d "/run/user/$(id -u)" ]; then
		export XDG_RUNTIME_DIR="/run/user/$(id -u)"
	fi

	xwayland_args="$(ps -u "$(id -un)" -o args= 2>/dev/null | grep -m 1 'Xwayland :' || true)"
	if [ -n "$xwayland_args" ]; then
		if [ -z "${DISPLAY:-}" ]; then
			export DISPLAY="$(printf '%s\n' "$xwayland_args" | sed -n 's/.*Xwayland \(:[0-9][^ ]*\).*/\1/p')"
			[ -n "${DISPLAY:-}" ] && echo "Using Xwayland display: $DISPLAY"
		fi
		if [ -z "${XAUTHORITY:-}" ]; then
			xauth="$(printf '%s\n' "$xwayland_args" | sed -n 's/.* -auth \([^ ]*\).*/\1/p')"
			if [ -n "$xauth" ] && [ -r "$xauth" ]; then
				export XAUTHORITY="$xauth"
				echo "Using Xauthority: $XAUTHORITY"
			fi
		fi
	fi
}

ensure_dependencies() {
	local missing=0
	local dependency
	local bgfx_dir="$ROOT_DIR/Source/3rdParty/bgfx/build/linux/$BGFX_ARCH/debug"
	local required_dependencies=(
		"$ROOT_DIR/Source/3rdParty/SDL2/Lib/Linux/$RUNTIME_ARCH/libSDL2.a"
		"$bgfx_dir/libbgfx.a"
		"$bgfx_dir/libbimg.a"
		"$bgfx_dir/libbimg_decode.a"
		"$bgfx_dir/libbx.a"
		"$bgfx_dir/libfcpp.a"
		"$bgfx_dir/libglsl_optimizer.a"
		"$bgfx_dir/libshaderc-lib.a"
		"$ROOT_DIR/Source/3rdParty/Wa/Lib/Linux/$WA_ARCH/libwa.a"
	)

	for dependency in "${required_dependencies[@]}"; do
		if [ ! -f "$dependency" ]; then
			echo "Missing dependency: $dependency"
			missing=1
		fi
	done

	if [ "$missing" -ne 0 ]; then
		echo "Building Linux native dependencies..."
		"$SCRIPT_DIR/build_lib_linux.sh" debug
	fi
}

build_rust_runtime() {
	cd "$ROOT_DIR/Source/Rust"
	rustup target add "$RUST_TARGET"
	cargo build --target "$RUST_TARGET"
	mkdir -p "lib/Linux/$RUNTIME_ARCH"
	cp "target/$RUST_TARGET/debug/libdora_runtime.a" "lib/Linux/$RUNTIME_ARCH/libdora_runtime.a"
}

build_linux_app() {
	local jobs
	jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"

	cd "$ROOT_DIR/Tools/tolua++"
	./build.sh

	cd "$ROOT_DIR/Projects/Linux"
	mkdir -p build
	if [ -f build/CMakeCache.txt ] && ! grep -q "CMAKE_HOME_DIRECTORY:INTERNAL=$ROOT_DIR/Projects/Linux" build/CMakeCache.txt; then
		echo "Removing stale Linux CMake cache..."
		rm -rf build/CMakeCache.txt build/CMakeFiles
	fi
	cd build
	cmake -DCMAKE_BUILD_TYPE=debug ..
	cmake --build . --parallel "$jobs"
}

"$SCRIPT_DIR/check_build_env.sh" linux run

ensure_dependencies
build_rust_runtime
build_linux_app
stop_running_dora
prepare_display_env
"$ROOT_DIR/Projects/Linux/build/dora-ssr" --asset "$ROOT_DIR/Assets"
