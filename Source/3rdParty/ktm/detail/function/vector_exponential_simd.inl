//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_EXPONENTIAL_SIMD_INL_
#define _KTM_VECTOR_EXPONENTIAL_SIMD_INL_

#include "vector_exponential_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

template <>
struct ktm::detail::vector_exponential_implement::sqrt<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _sqrth64_f32(x.st);
        return ret;
    }
};

template <>
struct ktm::detail::vector_exponential_implement::rsqrt<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _rsqrth64_f32(x.st);
        return ret;
    }
};

template <>
struct ktm::detail::vector_exponential_implement::recip<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _reciph64_f32(x.st);
        return ret;
    }
};

template <>
struct ktm::detail::vector_exponential_implement::fast_sqrt<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _sqrtl64_f32(x.st);
        return ret;
    }
};

template <>
struct ktm::detail::vector_exponential_implement::fast_rsqrt<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _rsqrtl64_f32(x.st);
        return ret;
    }
};

template <>
struct ktm::detail::vector_exponential_implement::fast_recip<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _recipl64_f32(x.st);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template <size_t N>
struct ktm::detail::vector_exponential_implement::sqrt<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _sqrth128_f32(x.st);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::vector_exponential_implement::rsqrt<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _rsqrth128_f32(x.st);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::vector_exponential_implement::recip<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _reciph128_f32(x.st);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::vector_exponential_implement::fast_sqrt<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _sqrtl128_f32(x.st);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::vector_exponential_implement::fast_rsqrt<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _rsqrtl128_f32(x.st);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::vector_exponential_implement::fast_recip<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _recipl128_f32(x.st);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#endif