#!/usr/bin/env python3
"""Stage opt-in APK test assets without editing the application's source assets."""
from pathlib import Path
import shutil
root=Path(__file__).resolve().parents[2]
out=root/'build/godot-android/test-assets'
shutil.copytree(root/'Assets',out,dirs_exist_ok=True)
(out/'Script/init.lua').write_text('return true\n')
print(out)
