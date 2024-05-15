//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_QUAT_CALC_SIMD_INL_
#define _KTM_QUAT_CALC_SIMD_INL_

#include "quat_calc_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

namespace ktm
{
namespace detail
{

KTM_FUNC skv::fv4 fv3_mul_fq(skv::fv4 v, skv::fv4 q) noexcept
{
    skv::fv4 q_opp = _neg128_f32(q);

    skv::fv4 tmp_0 = _shufft128_f32(q, q_opp, 2, 2, 3, 3);
    skv::fv4 tmp_1 = _shufft128_f32(q, q_opp, 1, 0, 1, 0); 

    skv::fv4 mul_x = _shufft128_f32(tmp_0, tmp_1, 2, 1, 3, 0); 
    skv::fv4 mul_y = _shufft128_f32(q, q_opp, 1, 0, 3, 2); 
    skv::fv4 mul_z = _shufft128_f32(tmp_1, tmp_0, 2, 1, 0, 3);

    skv::fv4 add_0 = _mul128_f32(_shuffo128_f32(v, 0, 0, 0, 0), mul_x); 
    skv::fv4 add_1 = _mul128_f32(_shuffo128_f32(v, 1, 1, 1, 1), mul_y); 
    skv::fv4 add_2 = _mul128_f32(_shuffo128_f32(v, 2, 2, 2, 2), mul_z); 

    return _add128_f32(add_0, _add128_f32(add_1, add_2)); 
}

KTM_FUNC skv::fv4 fq_mul_fq(skv::fv4 x, skv::fv4 y) noexcept
{
    skv::fv4 add_012 = fv3_mul_fq(x, y);
    skv::fv4 add_3 = _mul128_f32(_shuffo128_f32(x, 3, 3, 3, 3), y); 
    return _add128_f32(add_012, add_3);
}

}
}

template<>
struct ktm::detail::quat_calc_implement::mul<float>
{
    using Q = quat<float>;
    static KTM_INLINE Q call(const Q& x, const Q& y) noexcept
    {
        Q ret;
        ret.vector.st = fq_mul_fq(x.vector.st, y.vector.st);
        return ret;
    }
};

template<>
struct ktm::detail::quat_calc_implement::mul_to_self<float>
{
    using Q = quat<float>;
    static KTM_INLINE void call(Q& x, const Q& y) noexcept
    {
        x.vector.st = fq_mul_fq(x.vector.st, y.vector.st);
    }
};

template<>
struct ktm::detail::quat_calc_implement::act<float>
{
    using Q = quat<float>;
    static KTM_INLINE vec<3, float> call(const Q& q, const vec<3, float>& v) noexcept
    {
        vec<3, float> ret;
        constexpr union { unsigned int i; float f; } mask { 0x80000000 };
        skv::fv4 qi = _xor128_f32(q.vector.st, _set128_f32(0.f, mask.f, mask.f, mask.f));
        ret.st = fq_mul_fq(q.vector.st, fv3_mul_fq(v.st, qi));
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#endif