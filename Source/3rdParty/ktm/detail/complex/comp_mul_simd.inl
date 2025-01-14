//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMP_MUL_SIMD_INL_
#define _KTM_COMP_MUL_SIMD_INL_

#include "comp_mul_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

namespace ktm
{
namespace detail
{
namespace comp_mul_implement
{

KTM_FUNC skv::fv2 fc_mul_fc(skv::fv2 x, skv::fv2 y) noexcept
{
    constexpr union
    {
        unsigned int i;
        float f;
    } mask { 0x80000000 };

    skv::fv2 rxi = _xor64_f32(_shuffo64_f32(x, 0, 1), _set64_f32(mask.f, 0.f));
    skv::fv2 mul_0 = _mul64_f32(rxi, _shuffo64_f32(y, 0, 0));
    skv::fv2 mul_1 = _mul64_f32(x, _shuffo64_f32(y, 1, 1));
    return _add64_f32(mul_0, mul_1);
}

} // namespace comp_mul_implement
} // namespace detail
} // namespace ktm

template <>
KTM_INLINE void ktm::detail::comp_mul_implement::mul<float>(comp<float>& out, const comp<float>& x,
                                                            const comp<float>& y) noexcept
{
    out.st = fc_mul_fc(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::comp_mul_implement::act<float>(vec<2, float>& out, const comp<float>& c,
                                                            const vec<2, float>& v) noexcept
{
    constexpr union
    {
        unsigned int i;
        float f;
    } mask { 0x80000000 };

    skv::fv2 ci = _xor64_f32(c.st, _set64_f32(0.f, mask.f));
    out.st = fc_mul_fc(ci, v.st);
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON)

#endif