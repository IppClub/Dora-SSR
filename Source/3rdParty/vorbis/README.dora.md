# Dora retained aoTuV / Lancer Vorbis

The 76 retained files reconstruct exactly from the combined fork
`enzo1982/vorbis-aotuv-lancer` commit
`fbf05e8c7597065c371ff490c1c11e38c1bfec4b` plus the registered retained delta.
33 files, including COPYING, are byte-identical; 43 differ. Public headers map
from upstream `include/vorbis/` to this directory; `lib/` and COPYING keep paths.
The local info.c declares aoTuV Beta 6.03 (2020), LancerMod and a libvorbis 1.3.7
base. This is not the same code or public layout as Godot's original Vorbis.

Dora introduced these files in `a09bc240171f703e9b1be5298c005b0f9356084c`.
The record establishes an equivalent reconstruction baseline, not the original
checkout or the authorship/order of each retained difference. The patch preserves
all bytes, including whitespace; it does not classify every difference as a new
Dora-authored change. COPYING and original per-file notices remain unchanged.
Individual modification lineage and binary notice applicability remain separate
review items; do not infer one universal license from the baseline description.

The delta includes relative include paths, explicit C declarations, allocation
compatibility changes, and the preextrapolate_work field/allocation/release
path. This public state difference prevents direct state sharing with Godot.
Source/Audio/VorbisSources.c compiles 23 retained C files as an amalgamation,
with two local symbol aliases. Its input hash and include set are also recorded.
No source or decoder/encoder behavior was changed by this provenance audit.

```sh
python3 "$DORA_TEST_REPO/Test/Godot/verify_vorbis_source.py" \
  --archive /path/to/fork-fixed.tar.gz \
  --output /path/to/fresh-verification.json
```

Verification runs only the local audit and patch utility on temporary retained
files. It never executes upstream generators, compiles or loads the codec.
It requires exact archive identity, full local inventory, source hashes and
zero-fuzz/zero-offset patch reconstruction. Runtime, ABI, SIMD and actual
sharing are not accepted by this source-only check.

验证程序位于 Dora-Example；运行前设置 `DORA_TEST_REPO` 为该仓库绝对路径，并从 Dora-SSR 根目录执行，或显式设置 `DORA_ENGINE_ROOT`。
