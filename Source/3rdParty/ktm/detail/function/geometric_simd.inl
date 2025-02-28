//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_GEOMETRIC_SIMD_INL_
#define _KTM_GEOMETRIC_SIMD_INL_

#include "geometric_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

template <>
struct ktm::detail::geometric_implement::dot<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE float call(const V& x, const V& y) noexcept { return _cast64to32_f32(skv::dot1_fv2(x.st, y.st)); }
};

template <>
struct ktm::detail::geometric_implement::project<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        skv::fv2 dot_xy = skv::dot_fv2(x.st, y.st);
        skv::fv2 dot_yy = skv::dot_fv2(y.st, y.st);
        ret.st = _mul64_f32(_div64_f32(dot_xy, dot_yy), y.st);
        return ret;
    }
};

template <>
struct ktm::detail::geometric_implement::length<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE float call(const V& x) noexcept
    {
        skv::fv2 len_sq = skv::dot1_fv2(x.st, x.st);
        return _cast64to32_f32(_sqrth64_f32(len_sq));
    }
};

template <>
struct ktm::detail::geometric_implement::distance<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE float call(const V& x, const V& y) noexcept
    {
        V delta;
        delta.st = _sub64_f32(x.st, y.st);
        return length<2, float>::call(delta);
    }
};

template <>
struct ktm::detail::geometric_implement::normalize<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        skv::fv2 dot = skv::dot_fv2(x.st, x.st);
        skv::fv2 rsq = _rsqrth64_f32(dot);
        ret.st = _mul64_f32(rsq, x.st);
        return ret;
    }
};

template <>
struct ktm::detail::geometric_implement::reflect<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x, const V& n) noexcept
    {
        V ret;
        skv::fv2 dot = skv::dot_fv2(x.st, n.st);
        skv::fv2 mul_0 = _mul64_f32(n.st, dot);
        skv::fv2 mul_1 = _mul64_f32(mul_0, _dup64_f32(2.0f));
        ret.st = _sub64_f32(x.st, mul_1);
        return ret;
    }
};

template <>
struct ktm::detail::geometric_implement::refract<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x, const V& n, float eta) noexcept
    {
        skv::fv2 t_eta = _dup64_f32(eta);
        skv::fv2 one = _dup64_f32(1.f);
        skv::fv2 dot = skv::dot_fv2(n.st, x.st);
        skv::fv2 eta2 = _mul64_f32(t_eta, t_eta);
        skv::fv2 one_minus_cos2 = _sub64_f32(one, _mul64_f32(dot, dot));
        skv::fv2 k = _sub64_f32(one, _mul64_f32(eta2, one_minus_cos2));
        if (_cast64to32_f32(_cmpge64_f32(k, _dupzero64_f32())) == 0.f)
            return V();
        V ret;
        skv::fv2 sqrt_k = _sqrth64_f32(k);
        skv::fv2 fma = _madd64_f32(sqrt_k, t_eta, dot);
        ret.st = _sub64_f32(_mul64_f32(t_eta, x.st), _mul64_f32(fma, n.st));
        return ret;
    }
};

template <>
struct ktm::detail::geometric_implement::fast_project<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        skv::fv2 dot_xy = skv::dot_fv2(x.st, y.st);
        skv::fv2 dot_yy = skv::dot_fv2(y.st, y.st);
        ret.st = _mul64_f32(_mul64_f32(dot_xy, _recipl64_f32(dot_yy)), y.st);
        return ret;
    }
};

template <>
struct ktm::detail::geometric_implement::fast_length<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE float call(const V& x) noexcept
    {
        skv::fv2 len_sq = skv::dot1_fv2(x.st, x.st);
        return _cast64to32_f32(_sqrtl64_f32(len_sq));
    }
};

template <>
struct ktm::detail::geometric_implement::fast_distance<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE float call(const V& x, const V& y) noexcept
    {
        V delta;
        delta.st = _sub64_f32(x.st, y.st);
        return fast_length<2, float>::call(delta);
    }
};

template <>
struct ktm::detail::geometric_implement::fast_normalize<2, float>
{
    using V = vec<2, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        skv::fv2 dot = skv::dot_fv2(x.st, x.st);
        skv::fv2 rsq = _rsqrtl64_f32(dot);
        ret.st = _mul64_f32(rsq, x.st);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template <size_t N>
struct ktm::detail::geometric_implement::dot<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE float call(const V& x, const V& y) noexcept
    {
        if constexpr (N == 3)
            return _cast128to32_f32(skv::dot1_fv3(x.st, y.st));
        else
            return _cast128to32_f32(skv::dot1_fv4(x.st, y.st));
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::project<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        skv::fv4 dot_xy;
        skv::fv4 dot_yy;
        if constexpr (N == 3)
        {
            dot_xy = skv::dot_fv3(x.st, y.st);
            dot_yy = skv::dot_fv3(y.st, y.st);
        }
        else
        {
            dot_xy = skv::dot_fv4(x.st, y.st);
            dot_yy = skv::dot_fv4(y.st, y.st);
        }
        ret.st = _mul128_f32(_div128_f32(dot_xy, dot_yy), y.st);
        return ret;
    }
};

template <>
struct ktm::detail::geometric_implement::cross<3, float>
{
    using V = vec<3, float>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        skv::fv4 s_x = _shuffo128_f32(x.st, 3, 1, 0, 2);
        skv::fv4 s_y = _shuffo128_f32(y.st, 3, 1, 0, 2);
        skv::fv4 s_r = _sub128_f32(_mul128_f32(s_x, y.st), _mul128_f32(x.st, s_y));
        ret.st = _shuffo128_f32(s_r, 3, 1, 0, 2);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::length<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE float call(const V& x) noexcept
    {
        skv::fv4 len_sq;
        if constexpr (N == 3)
            len_sq = skv::dot1_fv3(x.st, x.st);
        else
            len_sq = skv::dot1_fv4(x.st, x.st);
        return _cast128to32_f32(_sqrth128_f32(len_sq));
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::distance<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE float call(const V& x, const V& y) noexcept
    {
        V delta;
        delta.st = _sub128_f32(x.st, y.st);
        return length<N, float>::call(delta);
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::normalize<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        skv::fv4 dot;
        if constexpr (N == 3)
            dot = skv::dot_fv3(x.st, x.st);
        else
            dot = skv::dot_fv4(x.st, x.st);
        skv::fv4 rsq = _rsqrth128_f32(dot);
        ret.st = _mul128_f32(rsq, x.st);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::reflect<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x, const V& n) noexcept
    {
        V ret;
        skv::fv4 dot;
        if constexpr (N == 3)
            dot = skv::dot_fv3(x.st, n.st);
        else
            dot = skv::dot_fv4(x.st, n.st);
        skv::fv4 mul_0 = _mul128_f32(n.st, dot);
        skv::fv4 mul_1 = _mul128_f32(mul_0, _dup128_f32(2.0f));
        ret.st = _sub128_f32(x.st, mul_1);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::refract<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x, const V& n, float eta) noexcept
    {
        skv::fv4 t_eta = _dup128_f32(eta);
        skv::fv4 one = _dup128_f32(1.f);
        skv::fv4 dot;
        if constexpr (N == 3)
            dot = skv::dot_fv3(n.st, x.st);
        else
            dot = skv::dot_fv4(n.st, x.st);
        skv::fv4 eta2 = _mul128_f32(t_eta, t_eta);
        skv::fv4 one_minus_cos2 = _sub128_f32(one, _mul128_f32(dot, dot));
        skv::fv4 k = _sub128_f32(one, _mul128_f32(eta2, one_minus_cos2));
        if (_cast128to32_f32(_cmpge128_f32(k, _dupzero128_f32())) == 0.f)
            return V();
        V ret;
        skv::fv4 sqrt_k = _sqrth128_f32(k);
        skv::fv4 fma = _madd128_f32(sqrt_k, t_eta, dot);
        ret.st = _sub128_f32(_mul128_f32(t_eta, x.st), _mul128_f32(fma, n.st));
        return ret;
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::fast_project<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        skv::fv4 dot_xy;
        skv::fv4 dot_yy;
        if constexpr (N == 3)
        {
            dot_xy = skv::dot_fv3(x.st, y.st);
            dot_yy = skv::dot_fv3(y.st, y.st);
        }
        else
        {
            dot_xy = skv::dot_fv4(x.st, y.st);
            dot_yy = skv::dot_fv4(y.st, y.st);
        }
        ret.st = _mul128_f32(_mul128_f32(dot_xy, _recipl128_f32(dot_yy)), y.st);
        return ret;
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::fast_length<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE float call(const V& x) noexcept
    {
        skv::fv4 len_sq;
        if constexpr (N == 3)
            len_sq = skv::dot1_fv3(x.st, x.st);
        else
            len_sq = skv::dot1_fv4(x.st, x.st);
        return _cast128to32_f32(_sqrtl128_f32(len_sq));
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::fast_distance<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE float call(const V& x, const V& y) noexcept
    {
        V delta;
        delta.st = _sub128_f32(x.st, y.st);
        return fast_length<N, float>::call(delta);
    }
};

template <size_t N>
struct ktm::detail::geometric_implement::fast_normalize<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        skv::fv4 dot;
        if constexpr (N == 3)
            dot = skv::dot_fv3(x.st, x.st);
        else
            dot = skv::dot_fv4(x.st, x.st);
        skv::fv4 rsq = _rsqrtl128_f32(dot);
        ret.st = _mul128_f32(rsq, x.st);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#endif