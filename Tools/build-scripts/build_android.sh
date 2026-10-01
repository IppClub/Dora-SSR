#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-debug}"
case "$MODE" in
 debug|--debug|-d) MODE=debug ;;
 release|--release|-r) MODE=release ;;
 *) echo "Usage: $0 [debug|release]" >&2; exit 1 ;;
esac
cd "$SCRIPT_DIR/../.."
exec xmake dora-package --platform=android --mode="$MODE"
