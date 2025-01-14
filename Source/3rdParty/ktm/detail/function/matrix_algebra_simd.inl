//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_ALGEBRA_SIMD_INL_
#define _KTM_MATRIX_ALGEBRA_SIMD_INL_

#include "matrix_algebra_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template <>
struct ktm::detail::matrix_algebra_implement::transpose<2, 2, float>
{
    using M = mat<2, 2, float>;
    using RetM = M;

    static KTM_INLINE RetM call(const M& m) noexcept
    {
        RetM ret;
        skv::fv4 tmp = _load128_f32(&m[0][0]);
        tmp = _shuffo128_f32(tmp, 3, 1, 2, 0);
        _store128_f32(&ret[0][0], tmp);
        return ret;
    }
};

template <>
struct ktm::detail::matrix_algebra_implement::transpose<3, 3, float>
{
    using M = mat<3, 3, float>;
    using RetM = M;

    static KTM_INLINE RetM call(const M& m) noexcept
    {
        RetM ret;
        const skv::fv4* in = &m[0].st;
        skv::fv4* out = &ret[0].st;

        skv::fv4 tmp_0 = _shufft128_f32(in[0], in[1], 1, 0, 1, 0);
        skv::fv4 tmp_1 = _shufft128_f32(in[0], in[1], 3, 2, 3, 2);
        out[0] = _shufft128_f32(tmp_0, in[2], 3, 0, 2, 0);
        out[1] = _shufft128_f32(tmp_0, in[2], 3, 1, 3, 1);
        out[2] = _shufft128_f32(tmp_1, in[2], 3, 2, 2, 0);

        return ret;
    }
};

template <>
struct ktm::detail::matrix_algebra_implement::transpose<4, 4, float>
{
    using M = mat<4, 4, float>;
    using RetM = M;

    static KTM_INLINE RetM call(const M& m) noexcept
    {
        RetM ret;
        const skv::fv4* in = &m[0].st;
        skv::fv4* out = &ret[0].st;

        skv::fv4 tmp_0 = _shufft128_f32(in[0], in[1], 1, 0, 1, 0);
        skv::fv4 tmp_2 = _shufft128_f32(in[0], in[1], 3, 2, 3, 2);
        skv::fv4 tmp_1 = _shufft128_f32(in[2], in[3], 1, 0, 1, 0);
        skv::fv4 tmp_3 = _shufft128_f32(in[2], in[3], 3, 2, 3, 2);
        out[0] = _shufft128_f32(tmp_0, tmp_1, 2, 0, 2, 0);
        out[1] = _shufft128_f32(tmp_0, tmp_1, 3, 1, 3, 1);
        out[2] = _shufft128_f32(tmp_2, tmp_3, 2, 0, 2, 0);
        out[3] = _shufft128_f32(tmp_2, tmp_3, 3, 1, 3, 1);

        return ret;
    }
};

template <size_t N, typename T>
struct ktm::detail::matrix_algebra_implement::transpose<
    N, N, T, std::enable_if_t<sizeof(T) == sizeof(float) && !std::is_same_v<T, float> && N >= 2 && N <= 4>>
{
    using M = mat<N, N, T>;
    using RetM = M;
    using FM = mat<N, N, float>;
    using FRetM = FM;

    static KTM_INLINE RetM call(const M& m) noexcept
    {
        FRetM ret = transpose<N, N, float>::call(reinterpret_cast<const FM&>(m));
        return *reinterpret_cast<RetM*>(&ret);
    }
};

template <>
struct ktm::detail::matrix_algebra_implement::determinant<3, float>
{
    using M = mat<3, 3, float>;

    static KTM_INLINE float call(const M& m) noexcept
    {
        const skv::fv4& c_0 = m[0].st;
        const skv::fv4& c_1 = m[1].st;
        const skv::fv4& c_2 = m[2].st;
        skv::fv4 mul_00 = _mul128_f32(_shufft128_f32(c_1, c_1, 3, 0, 2, 1), _shufft128_f32(c_2, c_2, 3, 1, 0, 2));
        skv::fv4 mul_01 = _mul128_f32(_shufft128_f32(c_1, c_1, 3, 1, 0, 2), _shufft128_f32(c_2, c_2, 3, 0, 2, 1));
        skv::fv4 sub_0 = _sub128_f32(mul_00, mul_01);

        return skv::radd_fv3(_mul128_f32(c_0, sub_0));
    }
};

template <>
struct ktm::detail::matrix_algebra_implement::determinant<4, float>
{
    using M = mat<4, 4, float>;

    static KTM_INLINE float call(const M& m) noexcept
    {
        const skv::fv4& c_0 = m[0].st;
        const skv::fv4& c_1 = m[1].st;
        const skv::fv4& c_2 = m[2].st;
        const skv::fv4& c_3 = m[3].st;

        skv::fv4 mul_0;
        {
            skv::fv4 mul_00 = _mul128_f32(_shuffo128_f32(c_2, 1, 0, 3, 2), _shuffo128_f32(c_3, 2, 1, 0, 3));
            skv::fv4 mul_01 = _mul128_f32(_shuffo128_f32(c_2, 2, 1, 0, 3), _shuffo128_f32(c_3, 1, 0, 3, 2));
            skv::fv4 sub_0 = _sub128_f32(mul_00, mul_01);
            mul_0 = _mul128_f32(_shuffo128_f32(c_1, 0, 3, 2, 1), sub_0);
        }

        skv::fv4 mul_1;
        {
            skv::fv4 mul_00 = _mul128_f32(_shuffo128_f32(c_2, 2, 1, 0, 3), _shuffo128_f32(c_3, 0, 3, 2, 1));
            skv::fv4 mul_01 = _mul128_f32(_shuffo128_f32(c_2, 0, 3, 2, 1), _shuffo128_f32(c_3, 2, 1, 0, 3));
            skv::fv4 sub_0 = _sub128_f32(mul_00, mul_01);
            mul_1 = _mul128_f32(_shuffo128_f32(c_1, 1, 0, 3, 2), sub_0);
        }

        skv::fv4 mul_2;
        {
            skv::fv4 mul_00 = _mul128_f32(_shuffo128_f32(c_2, 0, 3, 2, 1), _shuffo128_f32(c_3, 1, 0, 3, 2));
            skv::fv4 mul_01 = _mul128_f32(_shuffo128_f32(c_2, 1, 0, 3, 2), _shuffo128_f32(c_3, 0, 3, 2, 1));
            skv::fv4 sub_0 = _sub128_f32(mul_00, mul_01);
            mul_2 = _mul128_f32(_shuffo128_f32(c_1, 2, 1, 0, 3), sub_0);
        }

        skv::fv4 mul_3 = _mul128_f32(c_0, _add128_f32(_add128_f32(mul_0, mul_1), mul_2));
        return skv::rsub_fv4(mul_3);
    }
};

template <>
struct ktm::detail::matrix_algebra_implement::inverse<4, float>
{
    using M = mat<4, 4, float>;

    static KTM_INLINE M call(const M& m) noexcept
    {
        const skv::fv4& c_0 = m[0].st;
        const skv::fv4& c_1 = m[1].st;
        const skv::fv4& c_2 = m[2].st;
        const skv::fv4& c_3 = m[3].st;

        skv::fv4 fac_0;
        {
            skv::fv4 swp_0a = _shufft128_f32(c_3, c_2, 3, 3, 3, 3);
            skv::fv4 swp_0b = _shufft128_f32(c_3, c_2, 2, 2, 2, 2);

            skv::fv4 swp_00 = _shufft128_f32(c_2, c_1, 2, 2, 2, 2);
            skv::fv4 swp_01 = _shufft128_f32(swp_0a, swp_0a, 2, 0, 0, 0);
            skv::fv4 swp_02 = _shufft128_f32(swp_0b, swp_0b, 2, 0, 0, 0);
            skv::fv4 swp_03 = _shufft128_f32(c_2, c_1, 3, 3, 3, 3);

            skv::fv4 mul_00 = _mul128_f32(swp_00, swp_01);
            skv::fv4 mul_01 = _mul128_f32(swp_02, swp_03);
            fac_0 = _sub128_f32(mul_00, mul_01);
        }

        skv::fv4 fac_1;
        {
            skv::fv4 swp_0a = _shufft128_f32(c_3, c_2, 3, 3, 3, 3);
            skv::fv4 swp_0b = _shufft128_f32(c_3, c_2, 1, 1, 1, 1);

            skv::fv4 swp_00 = _shufft128_f32(c_2, c_1, 1, 1, 1, 1);
            skv::fv4 swp_01 = _shufft128_f32(swp_0a, swp_0a, 2, 0, 0, 0);
            skv::fv4 swp_02 = _shufft128_f32(swp_0b, swp_0b, 2, 0, 0, 0);
            skv::fv4 swp_03 = _shufft128_f32(c_2, c_1, 3, 3, 3, 3);

            skv::fv4 mul_00 = _mul128_f32(swp_00, swp_01);
            skv::fv4 mul_01 = _mul128_f32(swp_02, swp_03);
            fac_1 = _sub128_f32(mul_00, mul_01);
        }

        skv::fv4 fac_2;
        {
            skv::fv4 swp_0a = _shufft128_f32(c_3, c_2, 2, 2, 2, 2);
            skv::fv4 swp_0b = _shufft128_f32(c_3, c_2, 1, 1, 1, 1);

            skv::fv4 swp_00 = _shufft128_f32(c_2, c_1, 1, 1, 1, 1);
            skv::fv4 swp_01 = _shufft128_f32(swp_0a, swp_0a, 2, 0, 0, 0);
            skv::fv4 swp_02 = _shufft128_f32(swp_0b, swp_0b, 2, 0, 0, 0);
            skv::fv4 swp_03 = _shufft128_f32(c_2, c_1, 2, 2, 2, 2);

            skv::fv4 mul_00 = _mul128_f32(swp_00, swp_01);
            skv::fv4 mul_01 = _mul128_f32(swp_02, swp_03);
            fac_2 = _sub128_f32(mul_00, mul_01);
        }

        skv::fv4 fac_3;
        {
            skv::fv4 swp_0a = _shufft128_f32(c_3, c_2, 3, 3, 3, 3);
            skv::fv4 swp_0b = _shufft128_f32(c_3, c_2, 0, 0, 0, 0);

            skv::fv4 swp_00 = _shufft128_f32(c_2, c_1, 0, 0, 0, 0);
            skv::fv4 swp_01 = _shufft128_f32(swp_0a, swp_0a, 2, 0, 0, 0);
            skv::fv4 swp_02 = _shufft128_f32(swp_0b, swp_0b, 2, 0, 0, 0);
            skv::fv4 swp_03 = _shufft128_f32(c_2, c_1, 3, 3, 3, 3);

            skv::fv4 mul_00 = _mul128_f32(swp_00, swp_01);
            skv::fv4 mul_01 = _mul128_f32(swp_02, swp_03);
            fac_3 = _sub128_f32(mul_00, mul_01);
        }

        skv::fv4 fac_4;
        {
            skv::fv4 swp_0a = _shufft128_f32(c_3, c_2, 2, 2, 2, 2);
            skv::fv4 swp_0b = _shufft128_f32(c_3, c_2, 0, 0, 0, 0);

            skv::fv4 swp_00 = _shufft128_f32(c_2, c_1, 0, 0, 0, 0);
            skv::fv4 swp_01 = _shufft128_f32(swp_0a, swp_0a, 2, 0, 0, 0);
            skv::fv4 swp_02 = _shufft128_f32(swp_0b, swp_0b, 2, 0, 0, 0);
            skv::fv4 swp_03 = _shufft128_f32(c_2, c_1, 2, 2, 2, 2);

            skv::fv4 mul_00 = _mul128_f32(swp_00, swp_01);
            skv::fv4 mul_01 = _mul128_f32(swp_02, swp_03);
            fac_4 = _sub128_f32(mul_00, mul_01);
        }

        skv::fv4 fac_5;
        {
            skv::fv4 swp_0a = _shufft128_f32(c_3, c_2, 1, 1, 1, 1);
            skv::fv4 swp_0b = _shufft128_f32(c_3, c_2, 0, 0, 0, 0);

            skv::fv4 swp_00 = _shufft128_f32(c_2, c_1, 0, 0, 0, 0);
            skv::fv4 swp_01 = _shufft128_f32(swp_0a, swp_0a, 2, 0, 0, 0);
            skv::fv4 swp_02 = _shufft128_f32(swp_0b, swp_0b, 2, 0, 0, 0);
            skv::fv4 swp_03 = _shufft128_f32(c_2, c_1, 1, 1, 1, 1);

            skv::fv4 mul_00 = _mul128_f32(swp_00, swp_01);
            skv::fv4 mul_01 = _mul128_f32(swp_02, swp_03);
            fac_5 = _sub128_f32(mul_00, mul_01);
        }

        constexpr union
        {
            unsigned int i;
            float f;
        } neg { 0x80000000 };

        skv::fv4 sign_a = _set128_f32(0, neg.f, 0.f, neg.f);
        skv::fv4 sign_b = _set128_f32(neg.f, 0.f, neg.f, 0.f);

        // v_0 = { m[1][0], m[0][0], m[0][0], m[0][0] }
        skv::fv4 tmp_0 = _shufft128_f32(c_1, c_0, 0, 0, 0, 0);
        skv::fv4 v_0 = _shuffo128_f32(tmp_0, 2, 2, 2, 0);

        // v_0 = { m[1][1], m[0][1], m[0][1], m[0][1] }
        skv::fv4 tmp_1 = _shufft128_f32(c_1, c_0, 1, 1, 1, 1);
        skv::fv4 v_1 = _shuffo128_f32(tmp_1, 2, 2, 2, 0);

        // v_0 = { m[1][2], m[0][2], m[0][2], m[0][2] }
        skv::fv4 tmp_2 = _shufft128_f32(c_1, c_0, 2, 2, 2, 2);
        skv::fv4 v_2 = _shuffo128_f32(tmp_2, 2, 2, 2, 0);

        // v_0 = { m[1][3], m[0][3], m[0][3], m[0][3] }
        skv::fv4 tmp_3 = _shufft128_f32(c_1, c_0, 3, 3, 3, 3);
        skv::fv4 v_3 = _shuffo128_f32(tmp_3, 2, 2, 2, 0);

        // inv_0
        // + (v_1[0] * fac_0[0] - v_2[0] * fac_1[0] + v_3[0] * fac_2[0])
        // - (v_1[1] * fac_0[1] - v_2[1] * fac_1[1] + v_3[1] * fac_2[1])
        // + (v_1[2] * fac_0[2] - v_2[2] * fac_1[2] + v_3[2] * fac_2[2])
        // - (v_1[3] * fac_0[3] - v_2[3] * fac_1[3] + v_3[3] * fac_2[3])
        skv::fv4 inv_0;
        {
            // sign_b * (v_1 * fac_0 - v_2 * fac_1 + v_3 * fac_2)
            skv::fv4 mul_00 = _mul128_f32(v_1, fac_0);
            skv::fv4 mul_01 = _mul128_f32(v_2, fac_1);
            skv::fv4 mul_02 = _mul128_f32(v_3, fac_2);
            skv::fv4 sum_0 = _add128_f32(_sub128_f32(mul_00, mul_01), mul_02);
            inv_0 = _xor128_f32(sign_b, sum_0);
        }

        // inv_1
        // - (v_0[0] * fac_0[0] - v_2[0] * fac_3[0] + v_3[0] * fac_4[0])
        // + (v_0[0] * fac_0[1] - v_2[1] * fac_3[1] + v_3[1] * fac_4[1])
        // - (v_0[0] * fac_0[2] - v_2[2] * fac_3[2] + v_3[2] * fac_4[2])
        // + (v_0[0] * fac_0[3] - v_2[3] * fac_3[3] + v_3[3] * fac_4[3])
        skv::fv4 inv_1;
        {
            // sign_a * (v_0 * fac_0 - v_2 * fac_3 + v_3 * fac_4)
            skv::fv4 mul_00 = _mul128_f32(v_0, fac_0);
            skv::fv4 mul_01 = _mul128_f32(v_2, fac_3);
            skv::fv4 mul_02 = _mul128_f32(v_3, fac_4);
            skv::fv4 sum_0 = _add128_f32(_sub128_f32(mul_00, mul_01), mul_02);
            inv_1 = _xor128_f32(sign_a, sum_0);
        }

        // inv_2
        // + (v_0[0] * fac_1[0] - v_1[0] * fac_3[0] + v_3[0] * fac_5[0])
        // - (v_0[0] * fac_1[1] - v_1[1] * fac_3[1] + v_3[1] * fac_5[1])
        // + (v_0[0] * fac_1[2] - v_1[2] * fac_3[2] + v_3[2] * fac_5[2])
        // - (v_0[0] * fac_1[3] - v_1[3] * fac_3[3] + v_3[3] * fac_5[3])
        skv::fv4 inv_2;
        {
            // sign_b * (v_0 * fac_1 - v_1 * fac_3 + v_3 * fac_5)
            skv::fv4 mul_00 = _mul128_f32(v_0, fac_1);
            skv::fv4 mul_01 = _mul128_f32(v_1, fac_3);
            skv::fv4 mul_02 = _mul128_f32(v_3, fac_5);
            skv::fv4 sum_0 = _add128_f32(_sub128_f32(mul_00, mul_01), mul_02);
            inv_2 = _xor128_f32(sign_b, sum_0);
        }

        // inv_3
        // - (v_0[0] * fac_2[0] - v_1[0] * fac_4[0] + v_2[0] * fac_5[0])
        // + (v_0[0] * fac_2[1] - v_1[1] * fac_4[1] + v_2[1] * fac_5[1])
        // - (v_0[0] * fac_2[2] - v_1[2] * fac_4[2] + v_2[2] * fac_5[2])
        // + (v_0[0] * fac_2[3] - v_1[3] * fac_4[3] + v_2[3] * fac_5[3])
        skv::fv4 inv_3;
        {
            // sign_a * (v_0 * fac_2 - v_1 * fac_4 + v_2 * fac_5)
            skv::fv4 mul_00 = _mul128_f32(v_0, fac_2);
            skv::fv4 mul_01 = _mul128_f32(v_1, fac_4);
            skv::fv4 mul_02 = _mul128_f32(v_2, fac_5);
            skv::fv4 sum_0 = _add128_f32(_sub128_f32(mul_00, mul_01), mul_02);
            inv_3 = _xor128_f32(sign_a, sum_0);
        }

        // det
        // + m[0][0] * Inverse[0][0]
        // + m[0][1] * Inverse[1][0]
        // + m[0][2] * Inverse[2][0]
        // + m[0][3] * Inverse[3][0];
        skv::fv4 i_tmp_0 = _shufft128_f32(inv_0, inv_1, 0, 0, 0, 0);
        skv::fv4 i_tmp_1 = _shufft128_f32(inv_2, inv_3, 0, 0, 0, 0);
        skv::fv4 i_row_0 = _shufft128_f32(i_tmp_0, i_tmp_1, 3, 1, 3, 1);
        skv::fv4 i_dot = skv::dot_fv4(c_0, i_row_0);
        skv::fv4 recip_det = _reciph128_f32(i_dot);

        M ret;
        ret[0].st = _mul128_f32(inv_0, recip_det);
        ret[1].st = _mul128_f32(inv_1, recip_det);
        ret[2].st = _mul128_f32(inv_2, recip_det);
        ret[3].st = _mul128_f32(inv_3, recip_det);
        return ret;
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

template <>
struct ktm::detail::matrix_algebra_implement::determinant<3, int>
{
    using M = mat<3, 3, int>;

    static KTM_INLINE int call(const M& m) noexcept
    {
        const skv::sv4& c_0 = m[0].st;
        const skv::sv4& c_1 = m[1].st;
        const skv::sv4& c_2 = m[2].st;
        skv::sv4 mul_00 = _mul128_s32(_shuffo128_s32(c_1, 3, 0, 2, 1), _shuffo128_s32(c_2, 3, 1, 0, 2));
        skv::sv4 mul_01 = _mul128_s32(_shuffo128_s32(c_1, 3, 1, 0, 2), _shuffo128_s32(c_2, 3, 0, 2, 1));
        skv::sv4 sub_0 = _sub128_s32(mul_00, mul_01);
        return skv::radd_sv3(_mul128_s32(c_0, sub_0));
    }
};

template <>
struct ktm::detail::matrix_algebra_implement::determinant<4, int>
{
    using M = mat<4, 4, int>;

    static KTM_INLINE int call(const M& m) noexcept
    {
        const skv::sv4& c_0 = m[0].st;
        const skv::sv4& c_1 = m[1].st;
        const skv::sv4& c_2 = m[2].st;
        const skv::sv4& c_3 = m[3].st;

        skv::sv4 mul_0;
        {
            skv::sv4 mul_00 = _mul128_s32(_shuffo128_s32(c_2, 1, 0, 3, 2), _shuffo128_s32(c_3, 2, 1, 0, 3));
            skv::sv4 mul_01 = _mul128_s32(_shuffo128_s32(c_2, 2, 1, 0, 3), _shuffo128_s32(c_3, 1, 0, 3, 2));
            skv::sv4 sub_0 = _sub128_s32(mul_00, mul_01);
            mul_0 = _mul128_s32(_shuffo128_s32(c_1, 0, 3, 2, 1), sub_0);
        }

        skv::sv4 mul_1;
        {
            skv::sv4 mul_00 = _mul128_s32(_shuffo128_s32(c_2, 2, 1, 0, 3), _shuffo128_s32(c_3, 0, 3, 2, 1));
            skv::sv4 mul_01 = _mul128_s32(_shuffo128_s32(c_2, 0, 3, 2, 1), _shuffo128_s32(c_3, 2, 1, 0, 3));
            skv::sv4 sub_0 = _sub128_s32(mul_00, mul_01);
            mul_1 = _mul128_s32(_shuffo128_s32(c_1, 1, 0, 3, 2), sub_0);
        }

        skv::sv4 mul_2;
        {
            skv::sv4 mul_00 = _mul128_s32(_shuffo128_s32(c_2, 0, 3, 2, 1), _shuffo128_s32(c_3, 1, 0, 3, 2));
            skv::sv4 mul_01 = _mul128_s32(_shuffo128_s32(c_2, 1, 0, 3, 2), _shuffo128_s32(c_3, 0, 3, 2, 1));
            skv::sv4 sub_0 = _sub128_s32(mul_00, mul_01);
            mul_2 = _mul128_s32(_shuffo128_s32(c_1, 2, 1, 0, 3), sub_0);
        }

        skv::sv4 mul_3 = _mul128_s32(c_0, _add128_s32(_add128_s32(mul_0, mul_1), mul_2));
        return skv::rsub_sv4(mul_3);
    }
};

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#endif