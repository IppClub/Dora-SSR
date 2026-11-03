# Dora TinyEXR retained source

The retained `tinyexr.h` and original `README.md` exactly match syoyo/tinyexr
commit `834c4ce7955f2ae61edc802c697332baae2488c3` and bimg commit
`98a40e85334721446bbc2efe7bd4576d37952136`. No patch is required for these files.
Dora introduced the directory in `0836aa1d1fc898d712c078a46e2ca9e10b70402e`.
This establishes exact retained-source correspondence, not the unrecorded
original upstream checkout or a release version. Do not label it as Godot's
separate TinyEXR 1.0.12.

The original header contains multiple copyright/license notices, including
TinyEXR and embedded OpenEXR code. Preserve the full header. These two files
are not a complete inventory of compression backends or their notices;
miniz/zlib selection, compile macros, ABI and runtime ownership remain separate
checks. No source, codec behavior or original notice was changed by this record.

Reproduce offline using the fixed bimg archive and a directory containing
`tinyexr.h`, `README.md`, `commit.json` and `tree.json` (the pinned official Git
commit and tree API responses):

```sh
python3 "$DORA_TEST_REPO/Test/Godot/verify_tinyexr_source.py" \
  --upstream-dir /path/to/fixed-upstream-inputs \
  --bimg-archive /path/to/bimg-fixed.tar.gz \
  --output /path/to/fresh-verification.json
```

`UPSTREAM.json` fixes input SHA256, the upstream commit/tree and retained Git
blob hashes. Verification reads files and archive entries only, without network,
compilation, loading code or modifying retained source.

验证程序位于 Dora-Example；运行前设置 `DORA_TEST_REPO` 为该仓库绝对路径，并从 Dora-SSR 根目录执行，或显式设置 `DORA_ENGINE_ROOT`。
