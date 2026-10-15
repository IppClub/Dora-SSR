/*
 * Portable decoder-only libtheora amalgamation for Dora SSR.
 *
 * The included files are the unmodified libtheora 1.2.0 decoder sources.
 * Architecture-specific assembly is deliberately excluded so every Dora
 * target uses the same C implementation.
 */

#include "Source/apiwrapper.c"
#include "Source/bitpack.c"
#include "Source/decapiwrapper.c"
#include "Source/decinfo.c"
#include "Source/decode.c"
#include "Source/dequant.c"
#include "Source/fragment.c"
#include "Source/huffdec.c"
#include "Source/idct.c"
#include "Source/info.c"
#include "Source/internal.c"
#include "Source/quant.c"
#include "Source/state.c"
