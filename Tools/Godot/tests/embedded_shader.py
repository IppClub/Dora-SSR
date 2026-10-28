#!/usr/bin/env python3
"""Check the real embedded shader wrapper against fresh bin2c byte lists."""
import argparse
import json
import os
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path

root = Path(__file__).resolve().parents[3]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)
report = out / 'embedded-shader.json'
report.unlink(missing_ok=True)
bgfx = root / 'Source/3rdParty/bgfx'
names = ('bgfx_shader.sh', 'bgfx_compute.sh')
fixture = r'''
#include "BgfxEmbeddedShaders.hpp"
#include <cstring>
#include <fstream>
#include <iterator>
#include <string>
#include <string_view>
bool matches(std::string_view bytes, const char* path) {
    std::ifstream file(path, std::ios::binary);
    if (!file) return false;
    std::string expected((std::istreambuf_iterator<char>(file)), {});
    std::string copied;
    copied = bytes; // Same consumer operation as ShaderCompiler.cpp.
    return copied == expected;
}
int main(int argc, char** argv) {
    return argc != 3 || !matches(Dora::BgfxEmbeddedShaders::kBgfxShaderSh, argv[1])
        || !matches(Dora::BgfxEmbeddedShaders::kBgfxComputeSh, argv[2]);
}
'''
for terminated, trailing_comma in ((False, False), (False, True), (True, False), (True, True)):
    with tempfile.TemporaryDirectory(dir=out) as temporary:
        stage = Path(temporary)
        (stage / 'generated').mkdir()
        shutil.copy2(bgfx / 'dora/BgfxEmbeddedShaders.hpp', stage)
        for name in names:
            data = (bgfx / 'src' / name).read_bytes() + (b'\0' if terminated else b'')
            (stage / 'generated' / (name + '.h')).write_text(','.join(str(byte) for byte in data) + (',' if trailing_comma else ''))
        (stage / 'test.cpp').write_text(fixture)
        command = shlex.split(os.environ.get('CXX', 'c++'))
        subprocess.run(command + ['-std=c++20', '-Wall', '-Wextra', '-Werror',
            str(stage / 'test.cpp'), '-o', str(stage / 'test')], check=True)
        subprocess.run([str(stage / 'test'), *[str(bgfx / 'src' / name) for name in names]], check=True)
report.write_text(json.dumps({'passed': True,
    'scope': 'Embedded shader bounded source length and exact bytes; no GPU execution',
    'generated_inputs': ['unterminated-list', 'unterminated-list-trailing-comma',
                         'terminated-list', 'terminated-list-trailing-comma']}, indent=2) + '\n')
print('Fresh embedded shader source boundary: PASS')
