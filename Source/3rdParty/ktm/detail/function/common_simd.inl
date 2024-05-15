//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMMON_SIMD_INL_
#define _KTM_COMMON_SIMD_INL_

#include "common_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template<>
struct ktm::detail::common_implement::reduce_add<4, float>
{
    using V = vec<4, float>;
    static KTM_INLINE float call(const V& x) noexcept
    {
        return skv::radd_fv4(x.st);
    }
};

template<>
struct ktm::detail::common_implement::reduce_min<4, float>
{
    using V = vec<4, float>;
    static KTM_INLINE float call(const V& x) noexcept
    {
        return skv::rmin_fv4(x.st);
    }
};

template<>
struct ktm::detail::common_implement::reduce_max<4, float>
{
    using V = vec<4, float>;
    static KTM_INLINE float call(const V& x) noexcept
    {
        return skv::rmax_fv4(x.st);  
    }
};

template<size_t N>
struct ktm::detail::common_implement::abs<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _abs128_f32(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::min<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _min128_f32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::max<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _max128_f32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::clamp<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& v, const V& min, const V& max) noexcept
    {
        V ret;
        ret.st = _clamp128_f32(v.st, min.st, max.st);
        return ret; 
    }
};

template<size_t N>
struct ktm::detail::common_implement::floor<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = skv::floor_fv4(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::ceil<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = skv::ceil_fv4(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::round<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = skv::round_fv4(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::sqrt<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _sqrth128_f32(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::rsqrt<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _rsqrth128_f32(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::recip<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _reciph128_f32(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::fract<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        skv::fv4 floor = skv::floor_fv4(x.st);
        ret.st = _sub128_f32(x.st, floor);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::mod<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        skv::fv4 div = _div128_f32(x.st, y.st);
        skv::fv4 floor = skv::floor_fv4(div);
        ret.st = _sub128_f32(x.st, _mul128_f32(y.st, floor));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::lerp<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y, float t) noexcept
    {
        V ret;
        skv::fv4 t_t = _dup128_f32(t);
        ret.st = _madd128_f32(x.st, t_t, _sub128_f32(y.st, x.st));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::mix<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y, const V& t) noexcept
    {
        V ret;
        ret.st = _madd128_f32(x.st, t.st, _sub128_f32(y.st, x.st));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::step<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& edge, const V& x) noexcept
    {
        V ret;
        skv::fv4 cmp = _cmplt128_f32(x.st, edge.st);
        ret.st = _and128_f32(_dup128_f32(1.f), cmp);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::smoothstep<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& edge0, const V& edge1, const V& x) noexcept
    {
        V ret;
        skv::fv4 tmp = _div128_f32(_sub128_f32(x.st, edge0.st), _sub128_f32(edge1.st, edge0.st));
        tmp = _clamp128_f32(tmp, _dupzero128_f32(), _dup128_f32(1.f));
        ret.st = _mul128_f32(_mul128_f32(tmp, tmp), _sub128_f32(_dup128_f32(3.f), _mul128_f32(_dup128_f32(2.f), tmp)));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::fast_sqrt<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _sqrtl128_f32(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::fast_rsqrt<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _rsqrtl128_f32(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::fast_recip<N, float, std::enable_if_t<N == 3 || N == 4>>
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

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

template<>
struct ktm::detail::common_implement::reduce_add<4, int>
{
    using V = vec<4, int>;
    static KTM_INLINE int call(const V& x) noexcept
    {
        return skv::radd_sv4(x.st);
    }
};

template<size_t N>
struct ktm::detail::common_implement::abs<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _abs128_s32(x.st);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

template<>
struct ktm::detail::common_implement::reduce_min<4, int>
{
    using V = vec<4, int>;
    static KTM_INLINE int call(const V& x) noexcept
    {
        return skv::rmin_sv4(x.st);
    }
};

template<>
struct ktm::detail::common_implement::reduce_max<4, int>
{
    using V = vec<4, int>;
    static KTM_INLINE int call(const V& x) noexcept
    {
        return skv::rmax_sv4(x.st);
    }
};

template<size_t N>
struct ktm::detail::common_implement::min<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _min128_s32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::max<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _max128_s32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::common_implement::clamp<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& v, const V& min, const V& max) noexcept
    {
        V ret;
        ret.st = _clamp128_s32(v.st, min.st, max.st);
        return ret; 
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

template<>
struct ktm::detail::common_implement::abs<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _abs64_f32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::min<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _min64_f32(x.st, y.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::max<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _max64_f32(x.st, y.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::clamp<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& v, const V& min, const V& max) noexcept
    {
        V ret;
        ret.st = _clamp64_f32(v.st, min.st, max.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::floor<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = skv::floor_fv2(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::ceil<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = skv::ceil_fv2(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::round<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = skv::round_fv2(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::sqrt<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _sqrth64_f32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::rsqrt<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _rsqrth64_f32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::recip<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _reciph64_f32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::fract<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        skv::fv2 floor = skv::floor_fv2(x.st);
        ret.st = _sub64_f32(x.st, floor);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::mod<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        skv::fv2 div = _div64_f32(x.st, y.st);
        skv::fv2 floor = skv::floor_fv2(div);
        ret.st = _sub64_f32(x.st, _mul64_f32(y.st, floor));
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::lerp<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y, float t) noexcept
    {
        V ret;
        skv::fv2 t_t = _dup64_f32(t);
        ret.st = _madd64_f32(x.st, t_t, _sub64_f32(y.st, x.st));
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::mix<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y, const V& t) noexcept
    {
        V ret;
        ret.st = _madd64_f32(x.st, t.st, _sub64_f32(y.st, x.st));
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::step<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& edge, const V& x) noexcept
    {
        V ret;
        skv::fv2 cmp = _cmplt64_f32(x.st, edge.st);
        ret.st = _and64_f32(_dup64_f32(1.f), cmp);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::smoothstep<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& edge0, const V& edge1, const V& x) noexcept
    {
        V ret;
        skv::fv2 tmp = _div64_f32(_sub64_f32(x.st, edge0.st), _sub64_f32(edge1.st, edge0.st));
        tmp = _clamp64_f32(tmp, _dupzero64_f32(), _dup64_f32(1.f));
        ret.st = _mul64_f32(_mul64_f32(tmp, tmp), _sub64_f32(_dup64_f32(3.f), _mul64_f32(_dup64_f32(2.f), tmp)));
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::fast_sqrt<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _sqrtl64_f32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::fast_rsqrt<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _rsqrtl64_f32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::fast_recip<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _recipl64_f32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::abs<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _abs64_s32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::min<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _min64_s32(x.st, y.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::max<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _max64_s32(x.st, y.st);
        return ret;
    }
};

template<>
struct ktm::detail::common_implement::clamp<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& v, const V& min, const V& max) noexcept
    {
        V ret;
        ret.st = _clamp64_s32(v.st, min.st, max.st);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON)

#endif