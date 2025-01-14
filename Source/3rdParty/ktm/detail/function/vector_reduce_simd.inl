//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_REDUCE_SIMD_INL_
#define _KTM_VECTOR_REDUCE_SIMD_INL_

#include "vector_reduce_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template <>
struct ktm::detail::vector_reduce_implement::reduce_add<4, float>
{
    using V = vec<4, float>;

    static KTM_INLINE float call(const V& x) noexcept { return skv::radd_fv4(x.st); }
};

template <>
struct ktm::detail::vector_reduce_implement::reduce_min<4, float>
{
    using V = vec<4, float>;

    static KTM_INLINE float call(const V& x) noexcept { return skv::rmin_fv4(x.st); }
};

template <>
struct ktm::detail::vector_reduce_implement::reduce_max<4, float>
{
    using V = vec<4, float>;

    static KTM_INLINE float call(const V& x) noexcept { return skv::rmax_fv4(x.st); }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

template <>
struct ktm::detail::vector_reduce_implement::reduce_add<4, int>
{
    using V = vec<4, int>;

    static KTM_INLINE int call(const V& x) noexcept { return skv::radd_sv4(x.st); }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

template <>
struct ktm::detail::vector_reduce_implement::reduce_min<4, int>
{
    using V = vec<4, int>;

    static KTM_INLINE int call(const V& x) noexcept { return skv::rmin_sv4(x.st); }
};

template <>
struct ktm::detail::vector_reduce_implement::reduce_max<4, int>
{
    using V = vec<4, int>;

    static KTM_INLINE int call(const V& x) noexcept { return skv::rmax_sv4(x.st); }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#endif