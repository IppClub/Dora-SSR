//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MAT_MUL_SIMD_INL_
#define _KTM_MAT_MUL_SIMD_INL_

#include "mat_mul_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_AVX)

template <>
KTM_INLINE void ktm::detail::mat_mul_implement::mat_mul_mat<4, 4, 4, float>(mat<4, 4, float>& out,
                                                                            const mat<4, 4, float>& m1,
                                                                            const mat<4, 4, float>& m2) noexcept
{
    skv::fv8 m2_01 = _load256_f32(&m2[0][0]);
    skv::fv8 m2_23 = _load256_f32(&m2[2][0]);

    skv::fv8 m1_01 = _load256_f32(&m1[0][0]);
    skv::fv8 m1_23 = _load256_f32(&m1[2][0]);
    skv::fv8 m1_10 = _shuffo256_f32(m1_01, 3, 2, 1, 0, 7, 6, 5, 4);
    skv::fv8 m1_32 = _shuffo256_f32(m1_23, 3, 2, 1, 0, 7, 6, 5, 4);

    skv::fv8 m2_v_0 = _shuffo256_f32(m2_01, 5, 5, 5, 5, 0, 0, 0, 0);
    skv::fv8 m2_v_1 = _shuffo256_f32(m2_01, 7, 7, 7, 7, 2, 2, 2, 2);
    skv::fv8 m2_v_2 = _shuffo256_f32(m2_01, 4, 4, 4, 4, 1, 1, 1, 1);
    skv::fv8 m2_v_3 = _shuffo256_f32(m2_01, 6, 6, 6, 6, 3, 3, 3, 3);

    m2_01 = _mul256_f32(m1_01, m2_v_0);
    m2_01 = _madd256_f32(m2_01, m1_23, m2_v_1);
    m2_01 = _madd256_f32(m2_01, m1_10, m2_v_2);
    m2_01 = _madd256_f32(m2_01, m1_32, m2_v_3);

    m2_v_0 = _shuffo256_f32(m2_23, 5, 5, 5, 5, 0, 0, 0, 0);
    m2_v_1 = _shuffo256_f32(m2_23, 7, 7, 7, 7, 2, 2, 2, 2);
    m2_v_2 = _shuffo256_f32(m2_23, 4, 4, 4, 4, 1, 1, 1, 1);
    m2_v_3 = _shuffo256_f32(m2_23, 6, 6, 6, 6, 3, 3, 3, 3);

    m2_23 = _mul256_f32(m1_01, m2_v_0);
    m2_23 = _madd256_f32(m2_23, m1_23, m2_v_1);
    m2_23 = _madd256_f32(m2_23, m1_10, m2_v_2);
    m2_23 = _madd256_f32(m2_23, m1_32, m2_v_3);

    _store256_f32(&out[0][0], m2_01);
    _store256_f32(&out[2][0], m2_23);
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_AVX)

#if KTM_SIMD_ENABLE(KTM_SIMD_AVX2)

template <>
KTM_INLINE void ktm::detail::mat_mul_implement::mat_mul_mat<4, 4, 4, int>(mat<4, 4, int>& out, const mat<4, 4, int>& m1,
                                                                          const mat<4, 4, int>& m2) noexcept
{
    skv::sv8 m2_01 = _cast256_s32_f32(_load256_f32(&m2[0][0]));
    skv::sv8 m2_23 = _cast256_s32_f32(_load256_f32(&m2[2][0]));

    skv::sv8 m1_01 = _cast256_s32_f32(_load256_f32(&m1[0][0]));
    skv::sv8 m1_23 = _cast256_s32_f32(_load256_f32(&m1[2][0]));
    skv::sv8 m1_10 = _shuffo256_s32(m1_01, 3, 2, 1, 0, 7, 6, 5, 4);
    skv::sv8 m1_32 = _shuffo256_s32(m1_23, 3, 2, 1, 0, 7, 6, 5, 4);

    skv::sv8 m2_v_0 = _shuffo256_s32(m2_01, 5, 5, 5, 5, 0, 0, 0, 0);
    skv::sv8 m2_v_1 = _shuffo256_s32(m2_01, 7, 7, 7, 7, 2, 2, 2, 2);
    skv::sv8 m2_v_2 = _shuffo256_s32(m2_01, 4, 4, 4, 4, 1, 1, 1, 1);
    skv::sv8 m2_v_3 = _shuffo256_s32(m2_01, 6, 6, 6, 6, 3, 3, 3, 3);

    m2_01 = _mul256_s32(m1_01, m2_v_0);
    m2_01 = _madd256_s32(m2_01, m1_23, m2_v_1);
    m2_01 = _madd256_s32(m2_01, m1_10, m2_v_2);
    m2_01 = _madd256_s32(m2_01, m1_32, m2_v_3);

    m2_v_0 = _shuffo256_s32(m2_23, 5, 5, 5, 5, 0, 0, 0, 0);
    m2_v_1 = _shuffo256_s32(m2_23, 7, 7, 7, 7, 2, 2, 2, 2);
    m2_v_2 = _shuffo256_s32(m2_23, 4, 4, 4, 4, 1, 1, 1, 1);
    m2_v_3 = _shuffo256_s32(m2_23, 6, 6, 6, 6, 3, 3, 3, 3);

    m2_23 = _mul256_s32(m1_01, m2_v_0);
    m2_23 = _madd256_s32(m2_23, m1_23, m2_v_1);
    m2_23 = _madd256_s32(m2_23, m1_10, m2_v_2);
    m2_23 = _madd256_s32(m2_23, m1_32, m2_v_3);

    _store256_f32(&out[0][0], _cast256_f32_s32(m2_01));
    _store256_f32(&out[2][0], _cast256_f32_s32(m2_23));
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_AVX2)

#endif