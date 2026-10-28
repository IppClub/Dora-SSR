#!/usr/bin/env python3
"""Prepare the pinned Godot source for the versioned Dora bridge."""
from pathlib import Path
import shutil, sys
root = Path(__file__).resolve().parents[2]
source = Path(sys.argv[1]).resolve()
module = root / 'Tools/Godot/module'
shutil.copytree(module, source / 'modules/dora_bridge', dirs_exist_ok=True)
shutil.copy2(root / 'Source/Godot/GodotBridge.h', source / 'modules/dora_bridge/GodotBridge.h')
shutil.copy2(root / 'Source/Godot/GodotBridgeGL.h', source / 'modules/dora_bridge/GodotBridgeGL.h')
shutil.copy2(root / 'Source/Godot/GodotBridgeAudio.h', source / 'modules/dora_bridge/GodotBridgeAudio.h')
shutil.copy2(root / 'Source/Godot/GodotBridgeGLTargets.h', source / 'modules/dora_bridge/GodotBridgeGLTargets.h')
shutil.copy2(root / 'Source/Godot/GodotBridgeViewport.h', source / 'modules/dora_bridge/GodotBridgeViewport.h')
shutil.copy2(root / 'Source/Godot/GodotBridgeOutput.h', source / 'modules/dora_bridge/GodotBridgeOutput.h')
shutil.copy2(root / 'Source/Godot/GodotBridgeIME.h', source / 'modules/dora_bridge/GodotBridgeIME.h')
shutil.copy2(root / 'Source/Godot/GodotBridgeAndroid.h', source / 'modules/dora_bridge/GodotBridgeAndroid.h')
shutil.copy2(root / 'Source/Godot/GodotAudioQueue.h', source / 'modules/dora_bridge/GodotAudioQueue.h')
p = source / 'platform/macos/libgodot_macos.mm'
s = p.read_text()
include = '#include "modules/dora_bridge/display_server_dora_metal.h"'
if include not in s:
    assert '#include "os_macos.h"' in s
    s = s.replace('#include "os_macos.h"', '#include "os_macos.h"\n' + include)
    s = s.replace('os = new OS_MacOS_NSApp(', 'DisplayServer::register_create_function("dora-metal", DisplayServerDoraMetal::create, DisplayServerDoraMetal::drivers);\n\tos = new OS_MacOS_Headless(')
    p.write_text(s)
p = source / 'servers/rendering/renderer_rd/renderer_compositor_rd.cpp'
s = p.read_text()
if 'dora-metal' not in s:
    lines = s.splitlines(keepends=True)
    for i, line in enumerate(lines):
        if line.startswith('\t\t\tblit.pipelines[i] = RD::get_singleton()->render_pipeline_create('):
            lines[i] = '\t\t\tif (DisplayServer::get_singleton()->get_name() != "dora-metal") {\n\t' + line + '\t\t\t}\n'
    p.write_text(''.join(lines))
p = source / 'main/main.cpp'
s = p.read_text()
needle = 'void Main::setup_boot_logo() {\n'
if '// Dora windowless boot' not in s:
    assert needle in s
    p.write_text(s.replace(needle, needle + '\tif (DisplayServer::get_singleton()->get_name() == "dora-metal") return; // Dora windowless boot\n', 1))
(source / 'dora_bridge.exports').write_text('_dora_godot_get_api\n_dora_godot_get_audio_api\n_dora_godot_get_viewport_api\n_dora_godot_get_output_api\n_dora_godot_get_ime_api\n')

# With a threadless dummy driver, node deletion only marks audio playbacks for
# retirement. Mix the final fade-out and service deferred AudioServer frees
# after SceneTree deletion, while its driver/server and script languages live.
p = source / 'main/main.cpp'
s = p.read_text()
needle = '\tOS::get_singleton()->delete_main_loop();\n'
if '// Dora threadless audio shutdown' not in s:
    assert s.count(needle)==1
    s=s.replace(needle,needle+'''#ifdef MODULE_DORA_BRIDGE_ENABLED
\t// Dora threadless audio shutdown: retire playbacks after nodes are freed.
\tif (DisplayServer::get_singleton() &&
\t\t(DisplayServer::get_singleton()->get_name() == "dora-metal" || DisplayServer::get_singleton()->get_name() == "dora-gl")) {
\t\tint32_t final_audio[4096 * 2];
\t\tfor (int i = 0; i < 2; ++i) {
\t\t\tAudioDriverDummy::get_dummy_singleton()->mix_audio(4096, final_audio);
\t\t\tAudioServer::get_singleton()->update();
\t\t}
\t}
#endif
''',1)
    p.write_text(s)

p = source / 'platform/linuxbsd/libgodot_linuxbsd.cpp'
s = p.read_text()
include = '#include "modules/dora_bridge/gl/display_server_dora_gl.h"'
if include not in s:
    s = s.replace('#include "os_linuxbsd.h"', '#include "os_linuxbsd.h"\n' + include)
    s = s.replace('os = new OS_LinuxBSD();', 'os = new OS_LinuxBSD();\n\tDisplayServer::register_create_function("dora-gl", DisplayServerDoraGL::create, DisplayServerDoraGL::drivers);')
    p.write_text(s)
p = source / 'main/main.cpp'
s = p.read_text()
old = 'DisplayServer::get_singleton()->get_name() == "dora-metal") return; // Dora windowless boot'
new = '(DisplayServer::get_singleton()->get_name() == "dora-metal" || DisplayServer::get_singleton()->get_name() == "dora-gl")) return; // Dora windowless boot'
if old in s:
    p.write_text(s.replace(old,new))
(source / 'dora_bridge.map').write_text('{ global: dora_godot_get_api; dora_godot_get_gl_api; dora_godot_get_gl_targets_api; dora_godot_get_audio_api; dora_godot_get_output_api; dora_godot_get_ime_api; local: *; };\n')

p = source / 'platform/windows/libgodot_windows.cpp'
s = p.read_text()
include = '#include "modules/dora_bridge/gl/display_server_dora_gl.h"'
if include not in s:
    assert '#include "os_windows.h"' in s
    s = s.replace('#include "os_windows.h"', '#include "os_windows.h"\n' + include)
    needle = 'os = new OS_Windows(GetModuleHandle(nullptr));'
    assert needle in s
    s = s.replace(needle, needle + '\n\tDisplayServer::register_create_function("dora-gl", DisplayServerDoraGL::create, DisplayServerDoraGL::drivers);')
    p.write_text(s)

# On Unix-hosted MinGW builds, the upstream SharedLibrary builder otherwise
# keeps the host's .so suffix even though the produced image is a Windows DLL.
p = source / 'platform/windows/SCsub'
s = p.read_text()
old = 'prog = env.add_shared_library("#bin/godot", sources, PROGSUFFIX=env["PROGSUFFIX"])'
new = 'prog = env.add_shared_library("#bin/godot", sources, PROGSUFFIX=env["PROGSUFFIX"], SHLIBSUFFIX=".dll")'
if old in s:
    p.write_text(s.replace(old, new))
else:
    assert new in s, 'Unknown Windows shared-library target'

# Hand manual/offscreen rendering the exact step computed by the owning Main
# iteration. Pending RD resources must not also trigger Main's automatic draw,
# otherwise shader/particle clocks and drawn-frame counts advance twice.
p = source / 'main/main.cpp'
s = p.read_text()
if '// Dora manual render timing' not in s:
    include = '#include "modules/modules_enabled.gen.h" // For mono.\n'
    assert include in s
    s=s.replace(include,include+'''#ifdef MODULE_DORA_BRIDGE_ENABLED
#include "modules/dora_bridge/runtime_timing.h"
#endif
''',1)
    step = '\tdouble scaled_step = process_step * time_scale;\n'
    assert s.count(step)==1
    s=s.replace(step,step+'''#ifdef MODULE_DORA_BRIDGE_ENABLED
	// Dora manual render timing: preserve Main's effective scale and step.
	const String dora_display = DisplayServer::get_singleton()->get_name();
	const bool dora_manual_render = dora_display == "dora-metal" || dora_display == "dora-gl";
	if (dora_manual_render) DoraGodotRenderTiming::enqueue(scaled_step);
#endif
''',1)
    draw = '\tif (wants_present || has_pending_resources_for_processing) {\n'
    assert s.count(draw)==1
    s=s.replace(draw,'''	if (
#ifdef MODULE_DORA_BRIDGE_ENABLED
			!dora_manual_render &&
#endif
			(wants_present || has_pending_resources_for_processing)) {
''',1)
    p.write_text(s)

# Shader identity must not depend on the unspecified padding of C++ bitfields.
# HashMap copies a MaterialKey by value; Clang can leave padding different from
# the zeroed source key, making its own shader entry unfindable during teardown.
p = source / 'scene/resources/particle_process_material.h'
s = p.read_text()
if '// Dora particle-key semantic hashing' not in s:
    import re
    key_section=s[s.index('\tstruct MaterialKey {'):s.index('\tstruct ShaderData {')]
    fields=re.findall(r'uint64_t (\w+) : (\w+);',key_section)
    assert len(fields)==16 and fields[0]==('texture_mask','PARAM_MAX') and fields[-1]==('orbit_uses_curve_xyz','1'),fields
    old='''\t\tstatic uint32_t hash(const MaterialKey &p_key) {
\t\t\treturn hash_djb2_buffer((const uint8_t *)&p_key, sizeof(MaterialKey));
\t\t}
\t\tbool operator==(const MaterialKey &p_key) const {
\t\t\treturn memcmp(this, &p_key, sizeof(MaterialKey)) == 0;
\t\t}
\t\tbool operator<(const MaterialKey &p_key) const {
\t\t\treturn memcmp(this, &p_key, sizeof(MaterialKey)) < 0;
\t\t}'''
    lines=['\t\t// Dora particle-key semantic hashing: ignore bitfield padding.',
           '\t\tuint64_t packed() const {',
           '\t\t\tstatic_assert(('+ '+'.join(width for _,width in fields)+') <= 64);',
           '\t\t\tuint64_t value = 0;', '\t\t\tunsigned int offset = 0;']
    for name,width in fields:
        lines += ['\t\t\tvalue |= uint64_t('+name+') << offset;', '\t\t\toffset += '+width+';']
    lines += ['\t\t\treturn value;', '\t\t}',
              '\t\tstatic uint32_t hash(const MaterialKey &p_key) {',
              '\t\t\tconst uint64_t value = p_key.packed();',
              '\t\t\treturn hash_djb2_buffer((const uint8_t *)&value, sizeof(value));', '\t\t}',
              '\t\tbool operator==(const MaterialKey &p_key) const { return packed() == p_key.packed(); }',
              '\t\tbool operator<(const MaterialKey &p_key) const { return packed() < p_key.packed(); }']
    assert old in s
    p.write_text(s.replace(old,'\n'.join(lines),1))
