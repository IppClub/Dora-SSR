//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_QUAT_MUL_SIMD_INL_
#define _KTM_QUAT_MUL_SIMD_INL_

#include "quat_mul_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

namespace ktm
{
namespace detail
{
namespace quat_mul_implement
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

} // namespace quat_mul_implement
} // namespace detail
} // namespace ktm

template <>
KTM_INLINE void ktm::detail::quat_mul_implement::mul<float>(quat<float>& out, const quat<float>& x,
                                                            const quat<float>& y) noexcept
{
    out.st = fq_mul_fq(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::quat_mul_implement::act<float>(vec<3, float>& out, const quat<float>& q,
                                                            const vec<3, float>& v) noexcept
{
    constexpr union
    {
        unsigned int i;
        float f;
    } mask { 0x80000000 };

    skv::fv4 qi = _xor128_f32(q.st, _set128_f32(0.f, mask.f, mask.f, mask.f));
    out.st = fq_mul_fq(q.st, fv3_mul_fq(v.st, qi));
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#endif