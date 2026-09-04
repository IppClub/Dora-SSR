#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_ROOT="${1:-}"
OUTPUT_DIR="${2:-$ROOT_DIR/result/dora-ssr-web-package}"
ENGINE_PACKAGE="${DORA_EMSCRIPTEN_PACKAGE_DIR:-$ROOT_DIR/build/emscripten/dora-ssr-web}"

if [[ -z "$PROJECT_ROOT" || ! -d "$PROJECT_ROOT" ]]; then
	echo "Usage: $0 PROJECT_DIR [OUTPUT_DIR]" >&2
	exit 2
fi
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

if [[ ! -d "$ENGINE_PACKAGE" ]]; then
	echo "[ERROR] Generic Web package not found: $ENGINE_PACKAGE" >&2
	echo "        Run Tools/build-scripts/build_emscripten.sh first." >&2
	exit 1
fi
if [[ -e "$OUTPUT_DIR" ]]; then
	echo "[ERROR] Output already exists; choose another directory: $OUTPUT_DIR" >&2
	exit 1
fi

has_entry=0
for entry in init.lua init.yue init.tl init.wasm; do
	if [[ -f "$PROJECT_ROOT/$entry" ]]; then
		has_entry=1
		break
	fi
done
if [[ "$has_entry" != "1" ]]; then
	echo "[ERROR] Project root must contain init.lua, init.yue, init.tl, or init.wasm" >&2
	exit 1
fi

mkdir -p "$OUTPUT_DIR/game"
cp -a "$ENGINE_PACKAGE"/. "$OUTPUT_DIR/"

while IFS= read -r -d '' file; do
	relative="${file#"$PROJECT_ROOT"/}"
	case "$relative" in
		.git|.git/*) continue ;;
	esac
	target="$OUTPUT_DIR/game/$relative"
	mkdir -p "$(dirname "$target")"
	cp -a "$file" "$target"
done < <(find "$PROJECT_ROOT" -type f -print0)

node - "$OUTPUT_DIR/game" "$OUTPUT_DIR/dora-web-manifest.json" <<'NODE'
const fs = require('fs');
const path = require('path');

const projectRoot = path.resolve(process.argv[2]);
const manifestPath = path.resolve(process.argv[3]);
const projectName = path.basename(projectRoot);
const projectId = (projectName.replace(/[^A-Za-z0-9._-]+/g, '-').replace(/^[^A-Za-z0-9]+/, '').slice(0, 64) || 'project');
const files = [];

function visit(directory, prefix) {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
        if (entry.name === '.git') continue;
        const relative = prefix ? prefix + '/' + entry.name : entry.name;
        const fullPath = path.join(directory, entry.name);
        if (entry.isDirectory()) visit(fullPath, relative);
        else if (entry.isFile()) {
            const encoded = relative.split('/').map(part => encodeURIComponent(part)).join('/');
            files.push({ path: relative, url: 'game/' + encoded });
        }
    }
}

visit(projectRoot, '');
if (!files.some(file => /^init\.(lua|yue|tl|wasm)$/.test(file.path))) {
    throw new Error('packaged project has no supported init file');
}
fs.writeFileSync(manifestPath, JSON.stringify({
    version: 1,
    engine: 'Dora SSR Web',
    project: { id: projectId, name: projectName, files }
}, null, 2) + '\n');
NODE

echo "[INFO] Web game package: $OUTPUT_DIR"
echo "[INFO] Serve this directory with a web server and open index.html."
