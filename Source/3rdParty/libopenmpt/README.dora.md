# libopenmpt source provenance

Dora embeds the upstream libopenmpt 0.4.11 release sources required by
SoLoud's upstream `Openmpt` audio source.

- Upstream project: https://lib.openmpt.org/libopenmpt/
- Upstream source tag: https://source.openmpt.org/svn/openmpt/tags/libopenmpt-0.4.11
- Imported archive: `libopenmpt-0.4.11+release.makefile.tar.gz`
- Archive SHA-256: `a5c90100dcbb95cfee1ebe90bb5a74f9ce562e3c4da848386c2001ef567ecba6`
- License: BSD 3-Clause; see `LICENSE`

The files below `common`, `soundbase`, `soundlib`, `sounddsp`, and
`libopenmpt`, plus `common/svn_version.h`, are copied from that release. Dora
retains the upstream implementation with these integration patches:

- `common/mptUUID.h` explicitly includes `<stdexcept>`, because current MSVC
  no longer exposes `std::domain_error` through the older transitive include
  chain.
- `soundlib/load_j2b.cpp` includes Dora's canonical `miniz.h` instead of the
  bundled OpenMPT miniz 2.1.0 path.
- `common/BuildSettings.h` recognizes `MPT_BUILD_DORA`, selecting miniz over
  platform-default zlib so every Dora platform uses the same implementation.

`Source/3rdParty/Love/xmake.lua` is Dora-only build integration and compiles
the same libopenmpt core source groups selected by the upstream makefile. It
does not compile a private deflate implementation: unresolved `mz_*` symbols
are provided exactly once by the final Dora target from
`Source/3rdParty/Zip/miniz.c`.
