#!/usr/bin/env python3
"""Exercise native Content.read and its Lua binding with a built Dora executable."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import zipfile

LUA = r'''
local Content, App = Dora.Content, Dora.App
local checks = 0
local function equal(actual, expected, label)
    assert(actual == expected, label .. ": unexpected bytes")
    checks = checks + 1
end
local function pattern(offset, length)
    local bytes = {}
    for i = offset, offset + length - 1 do bytes[#bytes + 1] = string.char(i % 256) end
    return table.concat(bytes)
end
local ok, err = pcall(function()
    Content:addSearchPath(Content.assetPath .. "/../fixtures.zip")
    for _, name in ipairs({"data.bin", "Stored/MixedCase.bin", "Deflated/MixedCase.bin", "assets/data.bin"}) do
        equal(Content:read(name, 0, 256), pattern(0, 256), name .. " binary header")
        equal(Content:read(name, 65530, 4096), pattern(65530, 4096), name .. " across blocks")
        equal(Content:read(name, 262140, 100), pattern(262140, 4), name .. " short EOF")
        equal(Content:read(name, 262144, 10), "", name .. " at EOF")
        equal(Content:read(name, 262145, 10), "", name .. " beyond EOF")
        equal(Content:read(name, 0, 0), "", name .. " zero length")
        equal(Content:read(name, -1, 10), "", name .. " negative offset")
        equal(Content:read(name, 0, -1), "", name .. " negative length")
        equal(Content:read(name, 262140, math.maxinteger), pattern(262140, 4), name .. " large length")
        equal(Content:read(name, math.maxinteger, 1), "", name .. " large offset")
    end
    equal(Content:read("empty.bin", 0, 10), "", "empty file")
    equal(Content:read("empty-in-zip.bin", 0, 10), "", "empty ZIP entry")
    equal(Content:read("missing.bin", 0, 10), "", "missing file")
    equal(Content:read("Stored/missing.bin", 0, 10), "", "missing ZIP entry")
    equal(Content:read("", 0, 10), "", "empty filename")
    equal(Content:read("large.bin", 8589934592, 4), "TAIL", "offset above 4 GiB")
    equal(Content:read("large.bin", 0, 16), string.rep("\0", 16), "sparse header")
    equal(Content:read("large-compressed.bin", 64 * 1024 * 1024 - 4, 100), "TAIL", "large compressed tail")
    for i = 1, 500 do
        equal(Content:read("Deflated/MixedCase.bin", 0, 8), pattern(0, 8), "repeated prefix")
    end
    -- getAttr stops its ZIP reader early; repeated calls must release it too.
    for i = 1, 100 do
        local size, binary = Content:getAttr("Deflated/MixedCase.bin")
        assert(size == 262144 and binary)
    end
end)
Content:save(Content.assetPath .. "/result.json", ok and ('{"passed":true,"checks":' .. checks .. '}')
    or ('{"passed":false,"error":' .. string.format("%q", tostring(err)) .. '}'))
App.devMode = false
Dora.Director.systemScheduler:schedule(function() App:shutdown(); return true end)
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("executable", type=Path)
    args = parser.parse_args()
    executable = args.executable.resolve()
    with tempfile.TemporaryDirectory(prefix="dora-content-read-") as temporary:
        root = Path(temporary) / "assets"
        (root / "Script").mkdir(parents=True)
        (root / "Script/init.lua").write_text(LUA)
        data = bytes(range(256)) * 1024
        (root / "data.bin").write_bytes(data)
        (root / "empty.bin").touch()
        with (root / "large.bin").open("wb") as stream:
            stream.seek(8 * 1024**3)
            stream.write(b"TAIL")
        with zipfile.ZipFile(root.parent / "fixtures.zip", "w") as archive:
            archive.writestr("Stored/MixedCase.bin", data, compress_type=zipfile.ZIP_STORED)
            archive.writestr("Deflated/MixedCase.bin", data, compress_type=zipfile.ZIP_DEFLATED)
            archive.writestr("assets/data.bin", data, compress_type=zipfile.ZIP_DEFLATED)
            archive.writestr("empty-in-zip.bin", b"", compress_type=zipfile.ZIP_DEFLATED)
            info = zipfile.ZipInfo("large-compressed.bin")
            info.compress_type = zipfile.ZIP_DEFLATED
            with archive.open(info, "w") as stream:
                block = b"\0" * 1024**2
                for _ in range(63):
                    stream.write(block)
                stream.write(block[:-4] + b"TAIL")
        with (root / "engine.log").open("w") as log:
            subprocess.run([str(executable), "--asset", str(root)], stdout=log, stderr=log,
                           timeout=60, check=True)
        result_path = root / "result.json"
        if not result_path.exists():
            raise AssertionError((root / "engine.log").read_text()[-6000:])
        result = json.loads(result_path.read_text())
        assert result["passed"], result
        print(f"PASS: {result['checks']} native range reads; ordinary files, stored/deflated ZIP, binary bytes, EOF, 64-bit offsets and repeated early stops")


if __name__ == "__main__":
    main()
