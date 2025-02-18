//  MIfloat License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_EXPONENTIAL_SIMD_INL_
#define _KTM_EXPONENTIAL_SIMD_INL_

#include "exponential_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template <>
struct ktm::detail::exponential_implement::sqrt<float>
{
    static KTM_INLINE float call(float x) noexcept { return _cast128to32_f32(_sqrth128_f32(_dup128_f32(x))); }
};

template <>
struct ktm::detail::exponential_implement::rsqrt<float>
{
    static KTM_INLINE float call(float x) noexcept { return _cast128to32_f32(_rsqrth128_f32(_dup128_f32(x))); }
};

template <>
struct ktm::detail::exponential_implement::recip<float>
{
    static KTM_INLINE float call(float x) noexcept { return _cast128to32_f32(_reciph128_f32(_dup128_f32(x))); }
};

template <>
struct ktm::detail::exponential_implement::fast_sqrt<float>
{
    static KTM_INLINE float call(float x) noexcept { return _cast128to32_f32(_sqrtl128_f32(_dup128_f32(x))); }
};

template <>
struct ktm::detail::exponential_implement::fast_rsqrt<float>
{
    static KTM_INLINE float call(float x) noexcept { return _cast128to32_f32(_rsqrtl128_f32(_dup128_f32(x))); }
};

template <>
struct ktm::detail::exponential_implement::fast_recip<float>
{
    static KTM_INLINE float call(float x) noexcept { return _cast128to32_f32(_recipl128_f32(_dup128_f32(x))); }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#endif