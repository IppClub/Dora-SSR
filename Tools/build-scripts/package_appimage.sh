#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ARCH="$(uname -m)"
OUTPUT="${1:-$ROOT_DIR/dora-ssr-linux-$ARCH.AppImage}"
APPDIR="$(mktemp -d "${TMPDIR:-/tmp}/dora-ssr-appdir.XXXXXX")"
TOOLS_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dora-ssr-appimage-tools.XXXXXX")"

cleanup() {
	rm -rf "$APPDIR" "$TOOLS_DIR"
}
trap cleanup EXIT

case "$ARCH" in
	x86_64|aarch64) ;;
	*) echo "Unsupported Linux architecture: $ARCH" >&2; exit 1 ;;
esac

BINARY="$ROOT_DIR/Projects/Linux/build/dora-ssr"
if [ ! -x "$BINARY" ]; then
	echo "Missing executable: $BINARY" >&2
	exit 1
fi

mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" "$APPDIR/usr/share/dora-ssr"
install -Dm755 "$BINARY" "$APPDIR/usr/bin/dora-ssr"
cp -a "$ROOT_DIR/Assets" "$APPDIR/usr/share/dora-ssr/Assets"

# Release builds generate the Web IDE separately from the engine assets.
if [ -d "$ROOT_DIR/Tools/dora-dora/build" ]; then
	cp -a "$ROOT_DIR/Tools/dora-dora/build" "$APPDIR/usr/share/dora-ssr/Assets/www"
fi
if [ -f "$ROOT_DIR/Tools/dora-wa/wa.mod" ]; then
	mkdir -p "$APPDIR/usr/share/dora-ssr/Assets/dora-wa"
	cp "$ROOT_DIR/Tools/dora-wa/wa.mod" "$APPDIR/usr/share/dora-ssr/Assets/dora-wa/"
	[ -d "$ROOT_DIR/Tools/dora-wa/vendor" ] && cp -a "$ROOT_DIR/Tools/dora-wa/vendor" "$APPDIR/usr/share/dora-ssr/Assets/dora-wa/"
fi

# Bundle application libraries, but leave the host graphics stack and glibc alone.
while IFS= read -r dependency; do
	[ -f "$dependency" ] || continue
	name="$(basename "$dependency")"
	case "$name" in
		linux-vdso*|ld-linux*|libc.so*|libm.so*|libpthread*|librt.so*|libdl.so*|libresolv.so*|libutil.so*|libnss_*) continue ;;
		libGL*|libEGL*|libGLES*|libGLX*|libdrm*|libgbm*|libvulkan*) continue ;;
	esac
	cp -L "$dependency" "$APPDIR/usr/lib/$name"
done < <(lddtree -l "$APPDIR/usr/bin/dora-ssr")

patchelf --set-rpath '$ORIGIN/../lib' "$APPDIR/usr/bin/dora-ssr"

install -Dm755 "$ROOT_DIR/packaging/appimage/AppRun" "$APPDIR/AppRun"
install -Dm644 "$ROOT_DIR/packaging/appimage/dora-ssr.desktop" "$APPDIR/dora-ssr.desktop"
install -Dm644 "$ROOT_DIR/Assets/Image/logo.png" "$APPDIR/dora-ssr.png"

case "$ARCH" in
	x86_64) TOOL_ARCH=x86_64 ;;
	aarch64) TOOL_ARCH=aarch64 ;;
esac
curl --fail --location --silent --show-error \
	-o "$TOOLS_DIR/appimagetool" \
	"https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$TOOL_ARCH.AppImage"
chmod +x "$TOOLS_DIR/appimagetool"

mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT"
"$TOOLS_DIR/appimagetool" --appimage-extract-and-run "$APPDIR" "$OUTPUT"
chmod +x "$OUTPUT"
echo "Created $OUTPUT"
