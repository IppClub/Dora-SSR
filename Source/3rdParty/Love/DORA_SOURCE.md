# LOVE Source

This vendored source is pinned to the official LOVE 11.5 release.

- Upstream: `https://github.com/love2d/love.git`
- Tag: `11.5`
- Annotated tag object: `f834ab72481e95fa90abf573643c8dd168ae0660`
- Peeled commit: `6eb8d546736d5915a8b5af30b2cf33456dfdcb1a`
- Imported: 2026-08-02
- Imported content: a reproducible curated subset of the pinned upstream tree

Dora-owned adapters live in `Source/Love/`. The retained subset consists of:

- LOVE's unchanged Object/Proxy common runtime, built as `liblove` by xmake;
- backend-independent Data, Stream, hash, LZ4, noise, keyboard-table, thread,
  filesystem and Theora stream sources actually reused by Dora;
- the exact Love 11.5 Lua wrapper `.cpp` files read by the API parity audit.

LOVE's main loop, platform projects, SDL backends, renderer, audio mixer,
filesystem backend, bundled Lua, Box2D, and every unused bundled library are
intentionally omitted. The companion
`Dora-Example/Test/Love/UpstreamSourceSubsetAudit.mjs` locks the retained file
set and prevents an accidental full-tree import.

Upstream files should remain unchanged whenever possible. Required upstream
changes must be recorded as small, auditable patches in `Source/Love/Patches/`
and documented here. To refresh the subset, check out the peeled commit in a
temporary directory, copy it into this directory, then run
`DORA_SSR_ROOT=/path/to/Dora-SSR node /path/to/Dora-Example/Test/Love/UpstreamSourceSubsetAudit.mjs --prune`.
The command refuses an incomplete or unexpected import and
removes only files outside the manifest. Rerun it without `--prune`, followed
by the API parity, runtime, sanitizer, and platform build audits.

The complete upstream licensing notice is retained in `license.txt`.
