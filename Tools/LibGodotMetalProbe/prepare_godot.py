#!/usr/bin/env python3
"""Apply the experimental windowless Metal host patches to Godot 4.6-stable."""
from pathlib import Path
import shutil, sys
source = Path(sys.argv[1]).resolve()
module = Path(__file__).resolve().parent / 'godot_module'
shutil.copytree(module, source / 'modules/dora_metal_probe', dirs_exist_ok=True)
shutil.copy2(module / 'exports.txt', source / 'dora_metal_probe.exports')
p = source / 'platform/macos/libgodot_macos.mm'
s = p.read_text()
if '#include "modules/dora_metal_probe/display_server_dora_metal.h"' not in s:
    s = s.replace('#include "os_macos.h"', '#include "os_macos.h"\n#include "modules/dora_metal_probe/display_server_dora_metal.h"')
s = s.replace('os = new OS_MacOS_NSApp(', 'DisplayServer::register_create_function("dora-metal", DisplayServerDoraMetal::create, DisplayServerDoraMetal::drivers);\n\tos = new OS_MacOS_Headless(')
p.write_text(s)
# The stock RD compositor assumes a screen for its presentation pipelines.
# Keep offscreen rendering intact, skip only screen-only work for our driver.
p = source / 'servers/rendering/renderer_rd/renderer_compositor_rd.cpp'
s = p.read_text()
needle = '\t\t\tblit.pipelines[i] = RD::get_singleton()->render_pipeline_create('
if 'dora-metal' not in s:
    lines = s.splitlines(keepends=True)
    for i, line in enumerate(lines):
        if line.startswith(needle):
            lines[i] = '\t\t\tif (DisplayServer::get_singleton()->get_name() != "dora-metal") {\n\t' + line + '\t\t\t}\n'
    s = ''.join(lines)
    p.write_text(s)
p = source / 'main/main.cpp'
s = p.read_text()
needle = 'void Main::setup_boot_logo() {\n'
replacement = needle + '\tif (DisplayServer::get_singleton()->get_name() == "dora-metal") { return; } // No native screen.\n'
if replacement not in s:
    assert needle in s
    s = s.replace(needle, replacement, 1)
    p.write_text(s)
