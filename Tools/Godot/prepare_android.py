#!/usr/bin/env python3
"""Prepare only the Android copy of pinned Godot for host-driven LibGodot."""
from pathlib import Path
import sys
source=Path(sys.argv[1]).resolve()
p=source/'platform/android/detect.py';s=p.read_text()
old='"supported": ["mono"],';new='"supported": ["mono", "library"],'
if old in s:s=s.replace(old,new,1)
else:assert new in s
p.write_text(s)
p=source/'platform/android/java_godot_lib_jni.cpp';s=p.read_text()
if '// Dora embedded Android ownership' not in s:
    needle='static GodotJavaWrapper *godot_java = nullptr;';assert needle in s
    s=s.replace(needle,'''// Dora embedded Android ownership: upstream Java services, host-owned rendering.
#ifdef MODULE_DORA_BRIDGE_ENABLED
#include "modules/dora_bridge/android/embedded.h"
#include "modules/dora_bridge/gl/display_server_dora_gl.h"
#endif
'''+needle,1)
    old='static void _terminate(JNIEnv *env, bool p_restart = false) {';assert old in s
    s=s.replace(old,'static void _terminate(JNIEnv *env, bool p_restart = false, bool p_embedded_stopped = false) {',1)
    old='\t\tos_android->main_loop_end();';assert old in s
    s=s.replace(old,'\t\tif (!p_embedded_stopped) os_android->main_loop_end();',1)
    needle='extern "C" {';assert needle in s
    s=s.replace(needle,'''#ifdef MODULE_DORA_BRIDGE_ENABLED
void DoraGodotAndroid::cleanup() {
    _terminate(get_jni_env(), false, true);
    prepared=false;
}
#endif

'''+needle,1)
    needle='\tos_android = new OS_Android(godot_java, godot_io_java, p_use_apk_expansion);';assert needle in s
    s=s.replace(needle,needle+'''
#ifdef MODULE_DORA_BRIDGE_ENABLED
    DisplayServer::register_create_function("dora-gl", DisplayServerDoraGL::create, DisplayServerDoraGL::drivers);
#endif''',1)
    needle='\tError err = Main::setup(OS_Android::ANDROID_EXEC_PATH, cmdlen, (char **)cmdline, false);';assert needle in s
    s=s.replace(needle,'''#ifdef MODULE_DORA_BRIDGE_ENABLED
    bool dora_embedded=false;
    for (int i=0;i+1<cmdlen;++i) {
        if (strcmp(cmdline[i],"--display-driver")==0 && strcmp(cmdline[i+1],"dora-gl")==0) dora_embedded=true;
    }
#endif
'''+needle,1)
    needle='\tjava_class_wrapper = memnew(JavaClassWrapper);';assert needle in s
    s=s.replace(needle,needle+'''
#ifdef MODULE_DORA_BRIDGE_ENABLED
    DoraGodotAndroid::prepared=dora_embedded;
#endif''',1)
    p.write_text(s)
# Camera orientation must use Android's Java service rather than casting the
# windowless EGL display to DisplayServerAndroid.
p=source/'modules/camera/camera_android.cpp';s=p.read_text()
needle='\treturn DisplayServerAndroid::get_singleton()->get_display_rotation();'
if '// Dora embedded orientation' not in s:
    assert needle in s;s=s.replace(needle,'''    // Dora embedded orientation retains the upstream Android IO service.
    if (DisplayServer::get_singleton()->get_name()=="dora-gl") {
        auto *io=OS_Android::get_singleton()->get_godot_io_java();
        ERR_FAIL_NULL_V(io,0);return io->get_display_rotation();
    }
'''+needle,1);p.write_text(s)

# The upstream JNI unit does not include generated module availability macros.
p=source/'platform/android/java_godot_lib_jni.cpp';s=p.read_text()
include='#include "modules/modules_enabled.gen.h"'
if include not in s:
    marker='// Dora embedded Android ownership'
    assert marker in s;s=s.replace(marker,include+'\n'+marker,1);p.write_text(s)

# Main::setup initializes OS file factories before reading project.godot.
# Select host resource access there, rather than after setup has already failed.
p=source/'platform/android/java_godot_lib_jni.cpp';s=p.read_text()
needle='    bool dora_embedded=false;'
if 'DoraGodotAndroid::host_filesystem=dora_embedded;' not in s:
    marker='\tError err = Main::setup(OS_Android::ANDROID_EXEC_PATH, cmdlen, (char **)cmdline, false);'
    assert marker in s
    s=s.replace(marker,'#ifdef MODULE_DORA_BRIDGE_ENABLED\n    DoraGodotAndroid::host_filesystem=dora_embedded;\n#endif\n'+marker,1);p.write_text(s)
p=source/'platform/android/os_android.cpp';s=p.read_text()
if '// Dora host filesystem resources' not in s:
    s='#include "modules/modules_enabled.gen.h"\n#ifdef MODULE_DORA_BRIDGE_ENABLED\n#include "modules/dora_bridge/android/embedded.h"\n#endif\n'+s
    needle='if (use_apk_expansion) {';assert s.count(needle)==2
    s=s.replace(needle,'if (use_apk_expansion\n#ifdef MODULE_DORA_BRIDGE_ENABLED\n        || DoraGodotAndroid::host_filesystem // Dora host filesystem resources\n#endif\n    ) {')
    p.write_text(s)

# Pinned GLES3 canvas teardown deletes the same VAO/buffer pair twice. Android's
# emulator diagnoses the second delete, so keep exactly one matching release.
p=source/'drivers/gles3/rasterizer_canvas_gles3.cpp';s=p.read_text()
pair='\tglDeleteBuffers(1, &data.canvas_quad_vertices);\n\tglDeleteVertexArrays(1, &data.canvas_quad_array);'
duplicate=pair+'\n\n'+pair
if duplicate in s:s=s.replace(duplicate,pair,1)
else:assert s.count(pair)==1
p.write_text(s)

# Native Android root windows are device-sized. The embedded virtual display
# instead owns an offscreen texture and must accept host/project size requests.
p=source/'scene/main/window.cpp';s=p.read_text()
old='''#if defined(ANDROID_ENABLED)
	if (!get_parent() && is_inside_tree()) {
		// Can't set root window size on Android.'''
new='''#if defined(ANDROID_ENABLED)
	if (!get_parent() && is_inside_tree() && String(DisplayServer::get_singleton()->get_name()) != "dora-gl") {
		// Can't set native root window size on Android; Dora owns offscreen size.'''
if old in s:
    assert s.count(old)==3;s=s.replace(old,new)
else:assert s.count(new)==3
p.write_text(s)
