"""Generate disposable ZIP fixtures for the in-engine Mobile/PackageTest.ts.

Usage: python3 Tools/tests/mobile_package_fixtures.py <Dora appPath>
"""
import json
import pathlib
import struct
import sys
import zipfile

root = pathlib.Path(sys.argv[1]) / "mobile-package-fixtures"
root.mkdir(parents=True, exist_ok=True)


def package(name, entries):
    with zipfile.ZipFile(root / f"{name}.zip", "w", zipfile.ZIP_STORED) as archive:
        for path, data in entries.items():
            archive.writestr(path, data)


for name, path in {"traversal": "../escape.lua", "absolute": "/tmp/dora-package-escape.lua",
                   "backslash": "..\\escape.lua", "drive": "C:/escape.lua"}.items():
    package(name, {"init.lua": "return true", path: "bad"})
package("oversize", {"init.lua": "return true"})
archive = root / "oversize.zip"
data = bytearray(archive.read_bytes())
central = data.index(b"PK\x01\x02")
struct.pack_into("<I", data, central + 24, 513 * 1024 * 1024)
archive.write_bytes(data)
package("too-many", {f"file{i}.txt": "" for i in range(10001)})
(root / "corrupt.zip").write_bytes(b"not a ZIP")
package("missing-init", {"hello.txt": "no entry"})
package("bad-metadata", {"init.lua": "return true", "dora-package.json": "{"})
package("future-version", {"init.lua": "return true", "dora-package.json": json.dumps({"format": "dora-game", "version": 999})})
package("legacy", {"legacy/init.lua": "return true"})
package("mixed", {"init.lua": "return true", "mixed/asset.txt": "asset"})
print(root)
