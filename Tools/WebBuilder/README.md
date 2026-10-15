# WebBuilder

A command-line packaging tool for Dora SSR Web games. It turns a compiled
project entry (`init.lua`, optional audio and assets) into a distributable
single-site Web package, byte-compatible with what the Web IDE exports -
no IDE or browser required, so it can run in scripts and CI.

Addresses [#41](https://github.com/IppClub/Dora-SSR/issues/41): the
publishing flow currently needs the Web IDE and manual steps; this tool
makes Web packaging a one-command, automatable operation.

## How it works

The engine part of a Web package (engine chunks, HTML loader, licenses,
`index.html`) is identical for every project built against the same engine
build. `webbuild.py` therefore takes one **official Web IDE export as a
template** (any of your own exports works), keeps its engine parts, and
regenerates only the project parts:

```
template (official IDE export)     project inputs
   html-assets/0..3.js  ──keep──┐     init.lua ────────┐
   html-loader.js (loader body) │     Audio/*.wav      │
   runtime files, licenses      │     extra assets     │
                                ▼                       ▼
                     new html-assets/4..N.js (base64 chunks)
                     new html-loader.js config (manifest + records)
                     new runtime.json (sizes + sha256 of everything)
                                ▼
                     out directory + distributable ZIP
```

## Usage

```bash
python3 Tools/WebBuilder/webbuild.py \
    --template official-export.zip \
    --entry init.lua \
    --entry-src Script/Game/init.lua \
    --audio Audio/ \
    --extra Image/ \
    --out dist/game-web \
    --zip game-web.zip
```

| Option | Meaning |
| --- | --- |
| `--template` | An official Web IDE export (`.zip` or extracted directory). One export serves as the template for all subsequent builds. |
| `--entry` | Compiled project entry file, shipped as `init.lua`. |
| `--entry-src` | Optional source-tree copy of the entry (IDE convention: `Script/Game/init.lua`). |
| `--audio` | Directory of `.wav` files, shipped as `Audio/*` through the engine audio channel (playable via the engine on the web build). |
| `--extra` | Additional asset file or directory (repeatable; directory trees keep their top-level directory (e.g. `Image/hero.png`)). |
| `--lualib` | `auto` (default: `lualib_bundle.lua` next to the entry), `none`, or an explicit path. Shipped last in the manifest. |
| `--no-compat-patches` | Skip the `index.html` device compatibility patches (see below). |
| `--zip` | Also write a distributable ZIP. |

Every build ends with a built-in verification pass that reproduces the
Dora platform preflight: the ZIP content must match `runtime.json` exactly
(file list, sizes, sha256 hashes). The tool also checks manifest URLs, chunk delivery, sizes and hashes, including
Unicode and escaped filenames. Directory-only builds are verified too. The tool
exits non-zero if anything mismatches. The output directory must be empty; existing
files are never silently mixed into a new package.

## Format rules encoded in the tool

These rules were reverse-engineered from official IDE exports and verified
by the platform preflight; violating any of them produces a package that
fails preflight or misbehaves on devices:

1. **Manifest order**: `Audio/*` files first, then other assets, then the
   entry pair (`Script/Game/init.lua`, `init.lua`), `lualib_bundle.lua`
   last. The platform preflight pairs manifest entries in this order.
2. **Chunk naming**: project files become `html-assets/<N>.js` chunks where
   `N` continues after the engine chunks of the template (engine reserves
   `0..3`, projects start at `4`).
3. **`runtime.json` last**: it is generated after everything else and must
   list every file with size + sha256 (it does not list itself, matching
   the official export).
4. **`html-loader.js`**: only the trailing config JSON is replaced - the
   loader body and all engine records survive; project records are appended.
5. **Entry duplication**: the entry is shipped both as `init.lua` and under
   its `Script/Game/` source path, exactly like the IDE does.

## Compatibility patches

By default the tool patches `index.html` with fixes that were required to
ship real games; pass `--no-compat-patches` to keep the template's page
untouched:

- mobile viewport lock and touch handling (`touch-action`, tap highlight),
- audio unlock on the first user gesture (browser autoplay policies),

## Production validation

The packaging pipeline behind this tool was used to build and publish 14
Dora SSR Web games (each repository contains the game's Web package):

- https://atomgit.com/wangyue789/weft-painting
- https://atomgit.com/wangyue789/aurora-beat
- https://atomgit.com/wangyue789/firefly-circuit
- https://atomgit.com/wangyue789/liandan-peiliaotai
- https://atomgit.com/wangyue789/sky-greenhouse
- https://atomgit.com/wangyue789/star-raider
- https://atomgit.com/wangyue789/tidal-lighthouse
- https://atomgit.com/wangyue789/magnetic-scavenger
- https://atomgit.com/wangyue789/snowline-detour
- https://atomgit.com/wangyue789/silent-foley-studio
- https://atomgit.com/wangyue789/shadow-puppet-theatre
- https://atomgit.com/wangyue789/rainline-atelier
- https://atomgit.com/wangyue789/darkroom-chase
- https://atomgit.com/wangyue789/bird-visible-window

Equivalence check: rebuilding a published game from its source entry +
assets reproduces the official IDE export exactly - same manifest order,
identical project records (URL, chunk name, size, sha256) and byte-identical
engine and audio chunks.

## Requirements

- Python 3.7+ (standard library only).
- One official Web IDE export of the same engine version as the template.
