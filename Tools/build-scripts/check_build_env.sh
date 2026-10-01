#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM="${1:-host}"
case "$PLATFORM" in macos) PLATFORM=macosx ;; ios) PLATFORM=iphoneos ;; esac
cd "$SCRIPT_DIR/../.."
exec xmake doctor --platform="$PLATFORM"
