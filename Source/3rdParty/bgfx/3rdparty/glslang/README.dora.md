# Dora retained shader-tool source

The retained files, modes and licenses exactly match bgfx commit
`f1e0ba4b0bf9eaccf25889392c112ee98aeda272`. `UPSTREAM.json` records the
Khronos baseline, fixed archive, all retained paths/hashes and exact patch.
Dora introduced this subtree in `0836aa1d1fc898d712c078a46e2ca9e10b70402e`.
This establishes equivalent source reconstruction, not the unrecorded original
import checkout, patch authorship or complete upstream project contents.

glslang has 131 retained files: 127 byte-identical baseline files, 3 patched
headers (include/legacy compiler compatibility), and generated `build_info.h`.
The version header exactly matches fixed `build_info.h.tmpl` with 15.4.0 and
empty flavor from CHANGES.md. No upstream generator is executed by verification.

Original license files and per-file notices are unchanged. These libraries stay
separate from Godot's versions; this record does not approve C++ ABI, lifecycle,
allocator, source or binary sharing. Preserve all notices rather than assigning
one blanket license to the subtree.

Reproduce offline (select this component and a fresh output path):

```sh
python3 "$DORA_TEST_REPO/Test/Godot/verify_shader_source.py" \
  --component glslang \
  --archive /path/to/fixed-upstream.tar.gz \
  --bgfx-evidence /path/to/fixed-bgfx-evidence \
  --output /path/to/fresh-verification.json
```

The evidence directory contains `bgfx-commit.json` and `bgfx-tree.json` for the
fixed commit and real root tree. Verification checks complete local inventory,
Git blob identity/modes and zero-fuzz/zero-offset temporary reconstruction;
source and license files are read only.

验证程序位于 Dora-Example；运行前设置 `DORA_TEST_REPO` 为该仓库绝对路径，并从 Dora-SSR 根目录执行，或显式设置 `DORA_ENGINE_ROOT`。
