#!/usr/bin/env python3
"""Prepare only the isolated Web copy for host-driven LibGodot."""
from pathlib import Path
import re,sys
source=Path(sys.argv[1]).resolve()
p=source/'platform/web/detect.py';s=p.read_text()
if '"supported": ["library"],' not in s:
    needle='def get_flags():\n    return {\n';assert needle in s
    s=s.replace(needle,needle+'        "supported": ["library"],\n',1)
p.write_text(s)
p=source/'platform/web/SCsub';s=p.read_text()
marker='# Dora embedded Web library: the host owns main and all frame scheduling.'
exports=re.findall(r'EMSCRIPTEN_KEEPALIVE[^\n{]*?\b(dora_web_\w+)\(', (source/'modules/dora_bridge/web/web_api.cpp').read_text())
assert len(exports)>=15,exports
block=marker+'''
if env["library_type"] != "executable":
    sys_env.Append(LINKFLAGS=["--no-entry"])
    sys_env["LINKFLAGS"] = [flag for flag in sys_env["LINKFLAGS"] if flag != "-sOFFSCREEN_FRAMEBUFFER=1"]
    env["EXPORTED_FUNCTIONS"] = [name for name in env["EXPORTED_FUNCTIONS"] if name != "_main"]
    env["EXPORTED_RUNTIME_METHODS"] = [name for name in env["EXPORTED_RUNTIME_METHODS"] if name != "callMain"]
    env["EXPORTED_RUNTIME_METHODS"] += ["GL", "FS", "UTF8ToString", "stringToNewUTF8"]
    env["EXPORTED_FUNCTIONS"] += '''+repr(['_'+name for name in exports])
if marker not in s:
    needle='sys_env = env.Clone()';assert needle in s
    s=s.replace(needle,'''if env["library_type"] != "executable":
    web_files.remove("web_main.cpp")

'''+needle+'\n'+block,1)
    needle='build = sys_env.add_program(build_targets, web_files + ["web_runtime.cpp"])';assert needle in s
    s=s.replace(needle,'build = sys_env.add_program(build_targets, web_files + (["web_runtime.cpp"] if env["library_type"] == "executable" else []))',1)
else:
    start=s.index(marker);end=s.index('\n\n',start);s=s[:start]+block+s[end:]
p.write_text(s)

# LibGodot iteration bypasses web_main.cpp, so OS_Web's normal dirty-file
# polling does not run. Let Emscripten persist modified user:// nodes directly
# instead of synchronizing the full mount from the render bridge every frame.
p=source/'platform/web/js/libs/library_godot_os.js';s=p.read_text()
old='FS.mount(IDBFS, {}, path);'
new='FS.mount(IDBFS, { autoPersist: true }, path); // Dora embedded user:// persistence.'
if old in s:s=s.replace(old,new,1)
else:assert new in s
p.write_text(s)

# OS_Web registers native audio drivers even when the host selects Dummy. An
# unused Worklet has no worker to join; preserve the real join for active ones.
p=source/'platform/web/audio_driver_web.cpp';s=p.read_text()
old='''void AudioDriverWorklet::finish_driver() {
	quit = true; // Ask thread to quit.
	thread.wait_to_finish();
}'''
new='''void AudioDriverWorklet::finish_driver() {
	quit = true; // Ask thread to quit.
	if (thread.is_started()) thread.wait_to_finish(); // Dora: unused Web driver.
}'''
if old in s:s=s.replace(old,new,1)
else:assert new in s
p.write_text(s)
