# libopenmpt source provenance

Dora embeds the upstream libopenmpt 0.4.11 release sources required by
SoLoud's upstream `Openmpt` audio source.

- Upstream project: https://lib.openmpt.org/libopenmpt/
- Upstream source tag: https://source.openmpt.org/svn/openmpt/tags/libopenmpt-0.4.11
- Imported archive: `libopenmpt-0.4.11+release.makefile.tar.gz`
- Archive SHA-256: `a5c90100dcbb95cfee1ebe90bb5a74f9ce562e3c4da848386c2001ef567ecba6`
- License: BSD 3-Clause; see `LICENSE`

The files below `common`, `soundbase`, `soundlib`, `sounddsp`, `libopenmpt`,
and `include/miniz`, plus `common/svn_version.h`, are copied from that release.
Dora retains the upstream implementation and adds only an explicit
`#include <stdexcept>` to `common/mptUUID.h`, because current MSVC no longer
exposes `std::domain_error` through the older transitive include chain.
`Source/3rdParty/Love/xmake.lua` is Dora-only build integration and compiles
the same libopenmpt core source groups selected by the upstream makefile.
