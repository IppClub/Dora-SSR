# libtheoradec in Dora SSR

This directory contains the decoder-only, portable C subset of libtheora
1.2.0 from Xiph.Org commit `28fd5ec77f0ad0e07a371cef1047828116f6bd8a`.

Dora deliberately excludes the encoder, examples, tools, and all optional
x86, ARM, and C64x assembly implementations. Do not define `OC_X86_ASM`,
`OC_X86_64_ASM`, `OC_ARM_ASM`, or `OC_C64X_ASM` in platform builds. This keeps
the same decoder implementation on desktop, mobile, and WebAssembly targets.

The decoder uses the libogg sources under `Source/3rdParty/ogg`, compiled once
through `Source/3rdParty/ogg/OggSources.c`. Do not add
a second Ogg build target for Theora.

The upstream implementation sources are stored under `Source`. The xmake
target compiles the portable `TheoraSources.c` amalgamation into a standalone
static library, and Dora platform projects consume its outputs from `Lib`.
