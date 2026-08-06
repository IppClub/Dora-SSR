# Dora LOVE Integration

This directory owns Dora-specific LOVE integration code. The upstream LOVE
11.5 tree is kept separately in `Source/3rdParty/Love/`.

Directory responsibilities:

- `LoveRuntime.*`: ownership of one isolated Lua 5.5 state.
- `Backend/`: Dora implementations of LOVE platform, rendering, input, audio,
  filesystem, and virtual-window boundaries.
- `Patches/`: minimal patches that cannot be implemented outside the upstream
  tree. Every patch must record its reason and upstream file revision.
- `Tests/`: focused runtime, isolation, lifecycle, and compatibility tests.

The standalone CMake target in this directory is a P0 validation target. It
compiles the upstream LOVE runtime/root module against Dora's Lua 5.5 headers
without SDL main, SDL window, OpenGL presentation, or a second Lua library. It
also runs the isolated-state lifecycle tests without requiring the full Dora
application build.
