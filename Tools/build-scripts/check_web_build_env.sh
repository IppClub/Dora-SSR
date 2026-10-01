#!/usr/bin/env bash
# Check host requirements. Emscripten/Go/Rust installation is owned by xmake.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../.."
exec xmake dora-web-env
