# libogg retained sources in Dora

The six retained upstream source/notice files are equivalent to the official
libogg **1.3.5** release after the changes recorded in `patches/dora-layout.patch`:
relative include paths for Dora's flattened directory layout, and trailing
whitespace removal in two self-test lines. `UPSTREAM.json` records the archive,
checksums, upstream-to-local file mapping, and local file hashes.

This identification was established by exact reconstruction against official
release archives. The original import did not record an upstream commit; the
Dora import commit is `a09bc240171f703e9b1be5298c005b0f9356084c`.
Do not interpret the equivalent release as proof of an undocumented original
upstream commit or as a claim that this is libogg 1.3.6.

`config_types.h` is the retained local fixed-width integer configuration.
`OggSources.c` compiles `src/bitwise.c` and `src/framing.c` as one translation
unit. `xmake.lua` builds the standalone Ogg target. These three local files are
inventoried separately from the six upstream files. Theora and Vorbis consume
this implementation in Dora; avoid adding a second Ogg target for those users.

License text remains in `COPYING`. No Ogg implementation was upgraded during
this provenance audit. Godot's bundled Ogg has a different version/patch set;
ABI, allocator, cross-platform and behavioral checks remain necessary before
sharing a runtime implementation.

From the Dora repository root, verify a downloaded official archive without
modifying vendor sources:

```sh
python3 "$DORA_TEST_REPO/Test/Godot/verify_ogg_source.py" \
  --archive /path/to/libogg-1.3.5.tar.gz \
  --output /path/to/new-verification.json
```

验证程序位于 Dora-Example；运行前设置 `DORA_TEST_REPO` 为该仓库绝对路径，并从 Dora-SSR 根目录执行，或显式设置 `DORA_ENGINE_ROOT`。
