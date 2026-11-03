# Dora zlib source correspondence

The 26 retained upstream files correspond to zlib **1.3.1**, tag `v1.3.1`,
commit `51b7f2abdade71cd9bb0e7a373ef2610ec6f9daf`, with the local patch below.
This is a reproducible source correspondence; the original import did not
record its exact upstream checkout. Source identity does not prove binary ABI
compatibility or safe sharing with Godot's separately patched zlib.

- Source and per-file hashes: [UPSTREAM.json](UPSTREAM.json).
- Original license: [LICENSE](LICENSE), retained byte-for-byte from upstream.
- Local alteration: [patches/dora-unistd.patch](patches/dora-unistd.patch) adds
  `HAVE_UNISTD_H` when `__has_include(<unistd.h>)` succeeds in `zconf.h`.
  The other 25 retained files are byte-identical to the pinned source.

From the Dora repository root, verify an official archive against its pinned
hash, reconstruct the retained subset with the recorded patch, and compare
all retained bytes:

```sh
python3 "$DORA_TEST_REPO/Test/Godot/verify_zlib_source.py" \
  --archive /path/to/zlib-exact-commit.tar.gz \
  --output /path/to/fresh-zlib-source-verification.json
```

The verifier uses a temporary tree, never runs upstream build scripts, and
does not change these source files. Godot dependency work is tracked in
[Tools/Godot/TRACKING.md](../../../../Tools/Godot/TRACKING.md).

验证程序位于 Dora-Example；运行前设置 `DORA_TEST_REPO` 为该仓库绝对路径，并从 Dora-SSR 根目录执行，或显式设置 `DORA_ENGINE_ROOT`。
