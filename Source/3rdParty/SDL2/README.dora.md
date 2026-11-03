# Dora SDL2 retained source provenance

The original [DORA_SOURCE.md](DORA_SOURCE.md) records Dora fork commit
`05210686fc98508b2b7794721e42402231229092` based on official SDL commit
`e924f12a7b33678bc71dc96acf3c44142c72c553`. The header version is 2.31.0;
this identifies a development baseline, not a claim of a 2.31.0 release tag.
Both fixed archives are recorded in [UPSTREAM.json](UPSTREAM.json).

There are 1,213 retained files from both archives. Four platform configuration
headers differ between the official baseline and the fork. Nine retained files
have further Dora vendor edits: Linux configuration selection, KMSDRM cursor/EGL
handling, a PipeWire cast, and Cocoa input/event handling for embedded native UI.
An additional Linux configuration header is maintained by Dora; it is not
present in either archive. `DORA_SOURCE.md` and `xmake.lua` are local inputs.

Two patches preserve these layers without rewriting existing code or notices:

- [Official to fork](patches/official-to-dora-fork.patch) covers the retained
  subset only, excluding the fork's non-vendored Visual Studio project edits.
- [Fork to current vendor](patches/fork-to-dora-vendor.patch) covers the nine
  edits and the added Linux configuration header. This records its local
  contents; the original generator invocation for that header is not recovered.

Reproduce from the Dora repository root:

```sh
python3 "$DORA_TEST_REPO/Test/Godot/verify_sdl_source.py" \
  --official-archive /path/to/SDL-official-e924f12a.tar.gz \
  --fork-archive /path/to/SDL-dora-05210686.tar.gz \
  --output /path/to/fresh-report.json
```

The verifier reads both fixed archives, applies zero-fuzz patches only in a
temporary directory, and checks every retained file plus local inputs.
`.xmake/`, `build/` and `Lib/` contain local build state/artifacts and are
explicitly excluded; unknown files elsewhere and source symlinks are rejected.
The existing worktree uses CRLF for `cmake/CheckCPUArchitecture.cmake`, while
Git HEAD uses LF. Only this file accepts the recorded LF alternative; no other
bytes are ignored, and both forms are validated. No existing source is rewritten.

No upstream build scripts are executed. Source and notice correspondence does
not prove binary ABI, linked component license coverage, or library sharing.
Dora SDL2 and Godot SDL3 remain separate; an SDL major-version upgrade remains
an independent task.

验证程序位于 Dora-Example；运行前设置 `DORA_TEST_REPO` 为该仓库绝对路径，并从 Dora-SSR 根目录执行，或显式设置 `DORA_ENGINE_ROOT`。
