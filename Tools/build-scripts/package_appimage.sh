#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ARCH="$(uname -m)"
case "$ARCH" in
 aarch64|arm64) XMAKE_ARCH=arm64; FILE_ARCH=aarch64 ;;
 x86_64|amd64) XMAKE_ARCH=x86_64; FILE_ARCH=x86_64 ;;
 *) echo "Unsupported Linux architecture: $ARCH" >&2; exit 1 ;;
esac
cd "$ROOT_DIR"
xmake dora-package --platform=linux --arch="$XMAKE_ARCH" --mode=release
SOURCE="$ROOT_DIR/build/package/linux/$XMAKE_ARCH/release/dora-ssr-linux-$FILE_ARCH.AppImage"
OUTPUT="${1:-$ROOT_DIR/dora-ssr-linux-$FILE_ARCH.AppImage}"
if [ "$SOURCE" != "$OUTPUT" ] && [ ! "$SOURCE" -ef "$OUTPUT" ]; then
 mkdir -p "$(dirname "$OUTPUT")"
 cp "$SOURCE" "$OUTPUT"
fi
