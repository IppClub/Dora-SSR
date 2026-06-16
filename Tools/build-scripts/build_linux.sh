#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="${1:-debug}"

case "$BUILD_MODE" in
	debug|--debug|-d)
		BUILD_MODE="debug"
		;;
	release|--release|-r)
		BUILD_MODE="release"
		;;
	*)
		echo "Usage: $0 [debug|release]" >&2
		exit 1
		;;
esac

cd "$SCRIPT_DIR/../../Projects/Linux"
make "$BUILD_MODE"

echo "Built APP in 'Projects/Linux/build/dora-ssr' ($BUILD_MODE)"
