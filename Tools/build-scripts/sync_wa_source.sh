#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="${1:-${WA_SOURCE_DIR:-$HOME/Workspace/wa}}"
DEST_DIR="$SCRIPT_DIR/../../Source/3rdParty/Wa/Source"
MODULE_PATH="wa-lang.org/wa"

if [ ! -f "$SOURCE_DIR/go.mod" ]; then
	echo "Wa source repo not found: $SOURCE_DIR" >&2
	echo "Usage: $0 [/path/to/wa]" >&2
	exit 1
fi

if ! command -v go >/dev/null 2>&1; then
	echo "go is required to sync Wa source dependencies" >&2
	exit 1
fi

SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

mkdir -p "$TEMP_DIR/source"

rm -rf "$DEST_DIR"
mkdir -p "$(dirname "$DEST_DIR")"

python3 - "$SOURCE_DIR" "$TEMP_DIR/source" "$MODULE_PATH" <<'PY'
import json
import os
import shutil
import subprocess
import sys

source_dir, dest_dir, module_path = sys.argv[1:4]

targets = [
	("darwin", "arm64"),
	("darwin", "amd64"),
	("ios", "arm64"),
	("ios", "amd64"),
	("linux", "amd64"),
	("linux", "arm64"),
	("windows", "386"),
	("android", "arm"),
	("android", "arm64"),
	("android", "386"),
	("android", "amd64"),
]

source_fields = [
	"GoFiles",
	"CgoFiles",
	"CFiles",
	"CXXFiles",
	"MFiles",
	"HFiles",
	"FFiles",
	"SFiles",
	"SwigFiles",
	"SwigCXXFiles",
	"SysoFiles",
	"EmbedFiles",
]

root_files = [
	"go.mod",
	"go.sum",
	"main.go",
	"wa.gomobile",
	"wa.def",
	"LICENSE",
	"LICENSE.md",
	"README.md",
]

legal_names = {
	"LICENSE",
	"LICENSE.md",
	"LICENSE.txt",
	"COPYING",
	"COPYING.md",
	"NOTICE",
	"NOTICE.md",
	"PATENTS",
	"AUTHORS",
	"CONTRIBUTORS",
}


def parse_json_stream(text):
	decoder = json.JSONDecoder()
	index = 0
	while index < len(text):
		while index < len(text) and text[index].isspace():
			index += 1
		if index >= len(text):
			break
		obj, index = decoder.raw_decode(text, index)
		yield obj


def copy_file(source_file):
	if not os.path.isfile(source_file):
		return
	rel_path = os.path.relpath(source_file, source_dir)
	target_file = os.path.join(dest_dir, rel_path)
	os.makedirs(os.path.dirname(target_file), exist_ok=True)
	shutil.copy2(source_file, target_file)


def collect_go_list_files(work_dir):
	files = set()
	for goos, goarch in targets:
		env = os.environ.copy()
		env.update({
			"GOOS": goos,
			"GOARCH": goarch,
			"CGO_ENABLED": "1",
		})
		result = subprocess.run(
			["go", "list", "-deps", "-json", "."],
			cwd=work_dir,
			env=env,
			text=True,
			capture_output=True,
			check=True,
		)
		for package in parse_json_stream(result.stdout):
			if not package.get("Module") or package["Module"].get("Path") != module_path:
				continue
			package_dir = package.get("Dir")
			if not package_dir or not package_dir.startswith(source_dir):
				continue
			for field in source_fields:
				for name in package.get(field) or []:
					files.add(os.path.normpath(os.path.join(package_dir, name)))
			for name in os.listdir(package_dir):
				if name in legal_names:
					files.add(os.path.join(package_dir, name))
	return files


for name in root_files:
	copy_file(os.path.join(source_dir, name))

for source_file in collect_go_list_files(source_dir):
	copy_file(source_file)
PY

mv "$TEMP_DIR/source" "$DEST_DIR"

(
	cd "$DEST_DIR"
	go mod vendor
	python3 - <<'PY'
import json
import os
import shutil
import subprocess

root = os.getcwd()
targets = [
	("darwin", "arm64"),
	("darwin", "amd64"),
	("ios", "arm64"),
	("ios", "amd64"),
	("linux", "amd64"),
	("linux", "arm64"),
	("windows", "386"),
	("android", "arm"),
	("android", "arm64"),
	("android", "386"),
	("android", "amd64"),
]
source_fields = [
	"GoFiles",
	"CgoFiles",
	"CFiles",
	"CXXFiles",
	"MFiles",
	"HFiles",
	"FFiles",
	"SFiles",
	"SwigFiles",
	"SwigCXXFiles",
	"SysoFiles",
	"EmbedFiles",
]
keep_names = {
	"LICENSE",
	"LICENSE.md",
	"LICENSE.txt",
	"COPYING",
	"COPYING.md",
	"NOTICE",
	"NOTICE.md",
	"PATENTS",
	"AUTHORS",
	"CONTRIBUTORS",
	"modules.txt",
}


def parse_json_stream(text):
	decoder = json.JSONDecoder()
	index = 0
	while index < len(text):
		while index < len(text) and text[index].isspace():
			index += 1
		if index >= len(text):
			break
		obj, index = decoder.raw_decode(text, index)
		yield obj


keep = set()
for goos, goarch in targets:
	env = os.environ.copy()
	env.update({
		"GOOS": goos,
		"GOARCH": goarch,
		"CGO_ENABLED": "1",
		"GOFLAGS": "-mod=vendor",
	})
	result = subprocess.run(
		["go", "list", "-deps", "-json", "."],
		cwd=root,
		env=env,
		text=True,
		capture_output=True,
		check=True,
	)
	for package in parse_json_stream(result.stdout):
		package_dir = package.get("Dir")
		if not package_dir or not package_dir.startswith(root):
			continue
		for field in source_fields:
			for name in package.get(field) or []:
				keep.add(os.path.normpath(os.path.join(package_dir, name)))

for current_dir, _, filenames in os.walk(root):
	for name in filenames:
		if name in keep_names:
			keep.add(os.path.join(current_dir, name))

for current_dir, _, filenames in os.walk(os.path.join(root, "vendor")):
	for name in filenames:
		path = os.path.join(current_dir, name)
		if path not in keep:
			os.remove(path)

for current_dir, dirnames, _ in os.walk(os.path.join(root, "vendor"), topdown=False):
	for name in dirnames:
		path = os.path.join(current_dir, name)
		if not os.listdir(path):
			os.rmdir(path)
PY
)

echo "Synced Wa source subset to $DEST_DIR"
