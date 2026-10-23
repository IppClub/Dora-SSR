# YueScript in Dora

Dora vendors `src/yuescript/*` and `LICENSE` from
[YueScript](https://github.com/ippclub/YueScript).

## Upstream snapshot

- Synced on: 2026-10-23
- Upstream main: `55ed46a8c420d7a134539b5692ad949ab8aa6f97`
- Latest compiler commit: `4e3770ec50faf0b38c9bb4639191e4079df17155`
- Compiler version: `0.34.3`

The vendored source files and license match this upstream snapshot byte for
byte. Dora builds the compiler with its bundled Lua and UTF-8 implementation.

## Changes from the previous Dora snapshot

- Updated the compiler version from 0.34.2 to 0.34.3.
- Expand the first `;;` in a module path at its original position using the
  preserved default Lua path, for both macro imports and Lua module loading.
- Stop module lookup at the first matching path.
- Preserve the original default path across repeated module path setup.

Upstream CLI formatter/minifier changes are outside this embedded compiler
directory; Dora does not vendor the YueScript CLI.
