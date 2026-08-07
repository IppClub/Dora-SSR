# SoLoud source provenance

The SoLoud OpenMPT audio source used by Dora comes from the upstream
`RELEASE_20200207` tag, matching the `SOLOUD_VERSION 202002` core API:

- Upstream repository: https://github.com/jarikomppa/soloud
- Tag: `RELEASE_20200207`
- Commit: `c8e339fdce5c7107bdb3e64bbf707c8fd3449beb`
- License: zlib/libpng; see `LICENSE`

The `soloud_openmpt.h` and `audiosource/openmpt/soloud_openmpt.cpp` files are
the upstream files from that tag. Dora does not maintain a rewritten OpenMPT
audio source; its own integration is limited to build configuration and the
engine-side `AudioFile` wrapper.
