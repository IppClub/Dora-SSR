/*
 * Portable decoder-only libtheora amalgamation for Dora SSR.
 *
 * The included files are the unmodified libtheora 1.2.0 decoder sources.
 * Architecture-specific assembly is deliberately excluded so every Dora
 * target uses the same C implementation.
 */

#include "lib/apiwrapper.c"
#include "lib/bitpack.c"
#include "lib/decapiwrapper.c"
#include "lib/decinfo.c"
#include "lib/decode.c"
#include "lib/dequant.c"
#include "lib/fragment.c"
#include "lib/huffdec.c"
#include "lib/idct.c"
#include "lib/info.c"
#include "lib/internal.c"
#include "lib/quant.c"
#include "lib/state.c"
