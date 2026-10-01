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
