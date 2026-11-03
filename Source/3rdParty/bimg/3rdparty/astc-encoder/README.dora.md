# Dora astcenc retained-source provenance

The 34 retained files, including LICENSE.txt, exactly match bimg commit
`98a40e85334721446bbc2efe7bd4576d37952136`.
Dora introduced this directory in commit
`0836aa1d1fc898d712c078a46e2ca9e10b70402e`.

Arm baseline `234c8a48483a74892a0e6c49d1e100ad42fbdde4` declares
`project(astcencoder VERSION 4.8.0)`. Map Arm `Source/` to the local
`source/` directory, except `astcenc.h` maps to `include/astcenc.h`;
LICENSE.txt remains at the root. 32 files match without changes.
The recorded patch reconstructs the other two files: AVX2 comment differences,
and SSE header copyright text / MinGW popcount conditional differences.
The original notices are preserved; no new licensing assignment is made.

This identifies an equivalent source baseline and exact bimg correspondence,
not the unrecorded original Arm checkout or patch authorship/history.
No codec source was upgraded or modified by this provenance registration.
Godot's separate astcenc 5.3.0 remains independent; matching provenance does
not establish ABI, SIMD behavior, runtime ownership or sharing acceptance.

Reproduce without downloading or executing upstream code:

```sh
python3 "$DORA_TEST_REPO/Test/Godot/verify_astc_source.py" \
  --arm-archive /path/to/arm-fixed.tar.gz \
  --bimg-archive /path/to/bimg-fixed.tar.gz \
  --output /path/to/fresh-verification.json
```

`UPSTREAM.json` pins both archives, path mapping, source hashes and the exact
patch. The verifier reconstructs only retained files in a temporary directory,
requires zero-fuzz / zero-offset patch application, and checks the complete
local inventory. Keep build products outside this source directory.

验证程序位于 Dora-Example；运行前设置 `DORA_TEST_REPO` 为该仓库绝对路径，并从 Dora-SSR 根目录执行，或显式设置 `DORA_ENGINE_ROOT`。
