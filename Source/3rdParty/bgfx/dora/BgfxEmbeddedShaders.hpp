#pragma once

#include <string_view>

#if __has_include("generated/bgfx_shader.sh.h") && __has_include("generated/bgfx_compute.sh.h")
#define DORA_HAS_EMBEDDED_BGFX_SHADERS 1

namespace Dora::BgfxEmbeddedShaders {
inline constexpr const char kBgfxShaderShBytes[] = {
#include "generated/bgfx_shader.sh.h"
};

inline constexpr const char kBgfxComputeShBytes[] = {
#include "generated/bgfx_compute.sh.h"
};
// Native bin2c and Web generators differ in trailing comma/NUL conventions.
// Carry the byte length so string consumers never scan beyond either array.
inline constexpr std::string_view kBgfxShaderSh{kBgfxShaderShBytes,
    sizeof(kBgfxShaderShBytes) - (kBgfxShaderShBytes[sizeof(kBgfxShaderShBytes) - 1] == '\0' ? 1 : 0)};
inline constexpr std::string_view kBgfxComputeSh{kBgfxComputeShBytes,
    sizeof(kBgfxComputeShBytes) - (kBgfxComputeShBytes[sizeof(kBgfxComputeShBytes) - 1] == '\0' ? 1 : 0)};
} // namespace Dora::BgfxEmbeddedShaders

#else
#define DORA_HAS_EMBEDDED_BGFX_SHADERS 0
#endif
