#pragma once

#if __has_include("generated/bgfx_shader.sh.h") && __has_include("generated/bgfx_compute.sh.h")
#define DORA_HAS_EMBEDDED_BGFX_SHADERS 1

namespace Dora::BgfxEmbeddedShaders {
inline constexpr const char kBgfxShaderSh[] = {
#include "generated/bgfx_shader.sh.h"
};

inline constexpr const char kBgfxComputeSh[] = {
#include "generated/bgfx_compute.sh.h"
};
} // namespace Dora::BgfxEmbeddedShaders

#else
#define DORA_HAS_EMBEDDED_BGFX_SHADERS 0
#endif
