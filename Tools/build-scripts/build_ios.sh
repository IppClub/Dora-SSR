#!/usr/bin/env bash
# Compatibility entry point; no checked-in Xcode project or prebuilt runtimes.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="${1:-debug}"
case "$BUILD_MODE" in
  debug|--debug|-d) BUILD_MODE=debug ;;
  release|--release|-r) BUILD_MODE=release ;;
  *) echo "Usage: $0 [debug|release]" >&2; exit 1 ;;
esac
cd "$SCRIPT_DIR/../.."
exec xmake dora-package --platform=ios --appledev=simulator --mode="$BUILD_MODE"
