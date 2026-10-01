#!/usr/bin/env bash
# Compatibility entry point. DORA_WEB_* and JOBS are consumed by the Lua task.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../.."
exec xmake dora-web "$@"
