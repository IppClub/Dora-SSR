//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_CALC_SIMD_INL_
#define _KTM_VEC_CALC_SIMD_INL_

#include "vec_calc_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template<size_t N>
struct ktm::detail::vec_calc_implement::add<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _add128_f32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::add_to_self<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _add128_f32(x.st, y.st);
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::minus<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _sub128_f32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::minus_to_self<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _sub128_f32(x.st, y.st);
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::mul<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _mul128_f32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::mul_to_self<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _mul128_f32(x.st, y.st);
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::div<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _div128_f32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::div_to_self<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _div128_f32(x.st, y.st);
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::opposite<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
	    ret.st = _neg128_f32(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::add_scalar<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, float scalar) noexcept
    {
        V ret;
	    ret.st = _add128_f32(x.st, _dup128_f32(scalar));
        return ret;
    }

};

template<size_t N>
struct ktm::detail::vec_calc_implement::add_scalar_to_self<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE void call(V& x, float scalar) noexcept
    {
        x.st = _add128_f32(x.st, _dup128_f32(scalar));
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::minus_scalar<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, float scalar) noexcept
    {
        V ret;
	    ret.st = _sub128_f32(x.st, _dup128_f32(scalar));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::minus_scalar_to_self<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE void call(V& x, float scalar) noexcept
    {
        x.st = _sub128_f32(x.st, _dup128_f32(scalar));
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::mul_scalar<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, float scalar) noexcept
    {
        V ret;
	    ret.st = _mul128_f32(x.st, _dup128_f32(scalar));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::mul_scalar_to_self<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE void call(V& x, float scalar) noexcept
    {
        x.st = _mul128_f32(x.st, _dup128_f32(scalar));
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::div_scalar<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE V call(const V& x, float scalar) noexcept
    {   
        V ret;
	    ret.st = _div128_f32(x.st, _dup128_f32(scalar));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::div_scalar_to_self<N, float, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, float>;
    static KTM_INLINE void call(V& x, float scalar) noexcept
    {
        x.st = _div128_f32(x.st, _dup128_f32(scalar));
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2)

template<size_t N>
struct ktm::detail::vec_calc_implement::add<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _add128_s32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::add_to_self<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _add128_s32(x.st, y.st);
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::minus<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _sub128_s32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::minus_to_self<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _sub128_s32(x.st, y.st);
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::opposite<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _neg128_s32(x.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::add_scalar<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x, int scalar) noexcept
    {
        V ret;
        ret.st = _add128_s32(x.st, _dup128_s32(scalar));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::add_scalar_to_self<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE void call(V& x, int scalar) noexcept
    {
        x.st = _add128_s32(x.st, _dup128_s32(scalar));
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::minus_scalar<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x, int scalar) noexcept
    {
        V ret;
        ret.st = _sub128_s32(x.st, _dup128_s32(scalar));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::minus_scalar_to_self<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE void call(V& x, int scalar) noexcept
    {
        x.st = _sub128_s32(x.st, _dup128_s32(scalar));
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1)

template<size_t N>
struct ktm::detail::vec_calc_implement::mul<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _mul128_s32(x.st, y.st);
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::mul_to_self<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _mul128_s32(x.st, y.st);
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::mul_scalar<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE V call(const V& x, int scalar) noexcept
    {
        V ret;
        ret.st = _mul128_s32(x.st, _dup128_s32(scalar));
        return ret;
    }
};

template<size_t N>
struct ktm::detail::vec_calc_implement::mul_scalar_to_self<N, int, std::enable_if_t<N == 3 || N == 4>>
{
    using V = vec<N, int>;
    static KTM_INLINE void call(V& x, int scalar) noexcept
    {
        x.st = _mul128_s32(x.st, _dup128_s32(scalar));
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

template<>
struct ktm::detail::vec_calc_implement::add<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _add64_f32(x.st, y.st);
        return ret; 
    }
};

template<>
struct ktm::detail::vec_calc_implement::add_to_self<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _add64_f32(x.st, y.st);
    }
};

template<>
struct ktm::detail::vec_calc_implement::minus<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _sub64_f32(x.st, y.st);
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::minus_to_self<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _sub64_f32(x.st, y.st);
    }
};

template<>
struct ktm::detail::vec_calc_implement::mul<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _mul64_f32(x.st, y.st);
        return ret; 
    }
};

template<>
struct ktm::detail::vec_calc_implement::mul_to_self<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _mul64_f32(x.st, y.st);
    }
};

template<>
struct ktm::detail::vec_calc_implement::div<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _div64_f32(x.st, y.st);
        return ret; 
    }
};

template<>
struct ktm::detail::vec_calc_implement::div_to_self<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _div64_f32(x.st, y.st);
    }
};

template<>
struct ktm::detail::vec_calc_implement::opposite<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _neg64_f32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::add_scalar<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, float scalar) noexcept
    {
        V ret;
        ret.st = _add64_f32(x.st, _dup64_f32(scalar));
        return ret;
    }

};

template<>
struct ktm::detail::vec_calc_implement::add_scalar_to_self<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE void call(V& x, float scalar) noexcept
    {
        x.st = _add64_f32(x.st, _dup64_f32(scalar));
    }
};

template<>
struct ktm::detail::vec_calc_implement::minus_scalar<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, float scalar) noexcept
    {
        V ret;
        ret.st = _sub64_f32(x.st, _dup64_f32(scalar));
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::minus_scalar_to_self<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE void call(V& x, float scalar) noexcept
    {
        x.st = _sub64_f32(x.st, _dup64_f32(scalar));
    }
};

template<>
struct ktm::detail::vec_calc_implement::mul_scalar<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, float scalar) noexcept
    {
        V ret;
        ret.st = _mul64_f32(x.st, _dup64_f32(scalar));
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::mul_scalar_to_self<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE void call(V& x, float scalar) noexcept
    {
        x.st = _mul64_f32(x.st, _dup64_f32(scalar));
    }
};

template<>
struct ktm::detail::vec_calc_implement::div_scalar<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE V call(const V& x, float scalar) noexcept
    {   
        V ret;
        ret.st = _div64_f32(x.st, _dup64_f32(scalar));
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::div_scalar_to_self<2, float>
{
    using V = vec<2, float>;
    static KTM_INLINE void call(V& x, float scalar) noexcept
    {
        x.st = _div64_f32(x.st, _dup64_f32(scalar));
    }
};

template<>
struct ktm::detail::vec_calc_implement::add<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _add64_s32(x.st, y.st);
        return ret; 
    }
};

template<>
struct ktm::detail::vec_calc_implement::add_to_self<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _add64_s32(x.st, y.st);
    }
};

template<>
struct ktm::detail::vec_calc_implement::minus<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _sub64_s32(x.st, y.st);
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::minus_to_self<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _sub64_s32(x.st, y.st);
    }
};

template<>
struct ktm::detail::vec_calc_implement::mul<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        ret.st = _mul64_s32(x.st, y.st);
        return ret; 
    }
};

template<>
struct ktm::detail::vec_calc_implement::mul_to_self<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE void call(V& x, const V& y) noexcept
    {
        x.st = _mul64_s32(x.st, y.st);
    }
};

template<>
struct ktm::detail::vec_calc_implement::opposite<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        ret.st = _neg64_s32(x.st);
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::add_scalar<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x, int scalar) noexcept
    {
        V ret;
        ret.st = _add64_s32(x.st, _dup64_s32(scalar));
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::add_scalar_to_self<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE void call(V& x, int scalar) noexcept
    {
        x.st = _add64_s32(x.st, _dup64_s32(scalar));
    }
};

template<>
struct ktm::detail::vec_calc_implement::minus_scalar<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x, int scalar) noexcept
    {
        V ret;
        ret.st = _sub64_s32(x.st, _dup64_s32(scalar));
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::minus_scalar_to_self<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE void call(V& x, int scalar) noexcept
    {
        x.st = _sub64_s32(x.st, _dup64_s32(scalar));
    }
};

template<>
struct ktm::detail::vec_calc_implement::mul_scalar<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE V call(const V& x, int scalar) noexcept
    {
        V ret;
        ret.st = _mul64_s32(x.st, _dup64_s32(scalar));
        return ret;
    }
};

template<>
struct ktm::detail::vec_calc_implement::mul_scalar_to_self<2, int>
{
    using V = vec<2, int>;
    static KTM_INLINE void call(V& x, int scalar) noexcept
    {
        x.st = _mul64_s32(x.st, _dup64_s32(scalar));
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON)

#endif
