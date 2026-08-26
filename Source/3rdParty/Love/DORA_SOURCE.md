# LOVE Source

This vendored source is pinned to the official LOVE 11.5 release.

- Upstream: `https://github.com/love2d/love.git`
- Tag: `11.5`
- Annotated tag object: `f834ab72481e95fa90abf573643c8dd168ae0660`
- Peeled commit: `6eb8d546736d5915a8b5af30b2cf33456dfdcb1a`
- Imported: 2026-08-02
- Imported content: a curated subset of the pinned upstream tree

The vendored tree is the canonical integration source. Dora-specific changes
are reviewed and preserved by Git history rather than mirrored into patch
archives. This avoids requiring every vendor edit to update a duplicate delta.

## Ownership boundary

Dora-owned adapters live in `Source/Love/`. The vendored subset retains the
LOVE API and object layer where it can be reused without importing LOVE's
platform stack:

- Object/Proxy, Type, Reference, Module, Exception and deprecation runtime;
- Data, Stream, hash, compression, noise and common math implementations;
- Math, Data, Filesystem, Sound, Image, Font and Graphics object types and Lua
  wrappers used by the state-local Dora modules;
- Drawable, Texture, Image, Canvas, Mesh, SpriteBatch, ParticleSystem, Font,
  Text, Shader, Video and VideoStream public object contracts and wrappers;
- Thread/Channel, System, Timer, Event, Window and input module contracts;
- backend-neutral Physics object types and wrappers;
- Theora video-stream code and the selected headers or small libraries needed
  by the retained sources.

Dora supplies the concrete rendering, audio, filesystem, image decoding,
window, input, threading and PlayRho physics backends. Public wrapper parsing,
object identity and Love-visible lifetime behavior remain in the retained LOVE
layer wherever practical.

LOVE's main loop, platform projects, SDL backends, native renderer, audio
mixer, PhysFS backend, bundled Lua, Box2D and unused bundled libraries are
intentionally omitted.

## Maintenance

Upstream files should remain unchanged whenever possible. A required Dora
change is made directly in this vendored tree and should be isolated in a
reviewable Git commit whose message records the reason and compatibility
effect. No generated or consolidated patch file is maintained.

To refresh the subset:

1. Check out the peeled upstream commit in a temporary directory.
2. Compare it with this directory and copy only the selected source files.
3. Run:

   ```sh
   DORA_SSR_ROOT=/path/to/Dora-SSR \
     node /path/to/Dora-Example/Test/Love/UpstreamSourceSubsetAudit.mjs --prune
   ```

4. Rerun the audit without `--prune`, followed by API parity, runtime,
   sanitizer and platform build checks.

`Dora-Example/Test/Love/UpstreamSourceSubsetAudit.mjs` locks the retained file
set and the hashes of files that are expected to remain byte-identical to the
pinned upstream release. Git history is the source of truth for modified
vendored files.

The complete upstream licensing notice is retained in `license.txt`.
