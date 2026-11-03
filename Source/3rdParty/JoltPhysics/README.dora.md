# Dora Jolt source provenance

The retained Jolt 5.5.0 source corresponds byte for byte to official commit
`23dadd0e603f1b321142d4c74df07fce85064989`. The existing `JOLT_VERSION.txt`,
introduced in Dora commit `23ad2300feb643927bf7647ab03b9c17f8fcf4a9`, records
that same version and commit. All 444 retained upstream files, including
`LICENSE` and `README.md`, match the fixed official archive without patches.
This identifies the retained source; it does not restore the original importer
checkout or claim that the complete upstream repository is vendored.

[UPSTREAM.json](UPSTREAM.json) pins the official archive, each retained file,
and the local version marker. Dora's bridge and amalgamation are maintained
outside this upstream subtree. Local `.xmake/` state is a build cache and is
excluded from source provenance; unknown files elsewhere are rejected.

Reproduce from the Dora repository root with an already downloaded archive:

```sh
python3 "$DORA_TEST_REPO/Test/Godot/verify_jolt_source.py" \
  --archive /path/to/JoltPhysics-23dadd0e.tar.gz \
  --output /path/to/fresh-report.json
```

The verifier reads source and archive data without executing upstream scripts
or changing vendor files. This is source and notice correspondence only.
Dora Jolt 5.5.0 and Godot Jolt 5.4.0 remain separate; C++ ABI, feature bits,
allocator, Factory and lifecycle isolation have not been accepted for sharing.

验证程序位于 Dora-Example；运行前设置 `DORA_TEST_REPO` 为该仓库绝对路径，并从 Dora-SSR 根目录执行，或显式设置 `DORA_ENGINE_ROOT`。
