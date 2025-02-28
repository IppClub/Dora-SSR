//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_X86_INTRIN_H_
#define _KTM_X86_INTRIN_H_

#include "arch_def.h"

namespace intrin
{

#if KTM_SIMD_ENABLE(KTM_SIMD_SSE)

KTM_FUNC float cast128to32_f32(__m128 a) noexcept { return _mm_cvtss_f32(a); }

KTM_FUNC __m128 load128_f32(const void* p) noexcept { return _mm_loadu_ps(reinterpret_cast<const float*>(p)); }

KTM_FUNC void store128_f32(void* p, __m128 a) noexcept { _mm_storeu_ps(reinterpret_cast<float*>(p), a); }

KTM_FUNC __m128 dup128_f32(float a) noexcept { return _mm_set1_ps(a); }

KTM_FUNC __m128 dupzero128_f32() noexcept { return _mm_setzero_ps(); }

KTM_FUNC __m128 set128_f32(float a, float b, float c, float d) noexcept { return _mm_set_ps(a, b, c, d); }

template <size_t N3, size_t N2, size_t N1, size_t N0>
KTM_FUNC __m128 shuffle128_f32(__m128 a, __m128 b) noexcept
{
    return _mm_shuffle_ps(a, b, _MM_SHUFFLE(N3, N2, N1, N0));
}

template <size_t N3, size_t N2, size_t N1, size_t N0>
KTM_FUNC __m128 shuffle128_f32(__m128 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_AVX)
    return _mm_permute_ps(a, _MM_SHUFFLE(N3, N2, N1, N0));
#    elif KTM_SIMD_ENABLE(KTM_SIMD_SSE2)
    return _mm_castsi128_ps(_mm_shuffle_epi32(_mm_castps_si128(a), _MM_SHUFFLE(N3, N2, N1, N0)));
#    else
    return _mm_shuffle_ps(a, a, _MM_SHUFFLE(N3, N2, N1, N0));
#    endif
}

KTM_FUNC __m128 and128_f32(__m128 a, __m128 b) noexcept { return _mm_and_ps(a, b); }

KTM_FUNC __m128 or128_f32(__m128 a, __m128 b) noexcept { return _mm_or_ps(a, b); }

KTM_FUNC __m128 xor128_f32(__m128 a, __m128 b) noexcept { return _mm_xor_ps(a, b); }

KTM_FUNC __m128 add128_f32(__m128 a, __m128 b) noexcept { return _mm_add_ps(a, b); }

KTM_FUNC __m128 sub128_f32(__m128 a, __m128 b) noexcept { return _mm_sub_ps(a, b); }

KTM_FUNC __m128 mul128_f32(__m128 a, __m128 b) noexcept { return _mm_mul_ps(a, b); }

KTM_FUNC __m128 div128_f32(__m128 a, __m128 b) noexcept { return _mm_div_ps(a, b); }

KTM_FUNC __m128 madd128_f32(__m128 a, __m128 b, __m128 c) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_FMA)
    return _mm_fmadd_ps(b, c, a);
#    else
    return _mm_add_ps(a, _mm_mul_ps(b, c));
#    endif
}

KTM_FUNC __m128 neg128_f32(__m128 a) noexcept
{
    constexpr union
    {
        unsigned int i;
        float f;
    } mask { 0x80000000 };

    return _mm_xor_ps(a, _mm_set1_ps(mask.f));
}

KTM_FUNC __m128 abs128_f32(__m128 a) noexcept
{
    constexpr union
    {
        unsigned int i;
        float f;
    } mask { 0x7fffffff };

    return _mm_and_ps(a, _mm_set1_ps(mask.f));
}

KTM_FUNC __m128 max128_f32(__m128 a, __m128 b) noexcept { return _mm_max_ps(a, b); }

KTM_FUNC __m128 min128_f32(__m128 a, __m128 b) noexcept { return _mm_min_ps(a, b); }

KTM_FUNC __m128 cmpeq128_f32(__m128 a, __m128 b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_AVX)
    return _mm_cmp_ps(a, b, _CMP_EQ_OQ);
#    else
    return _mm_cmpeq_ps(a, b);
#    endif
}

KTM_FUNC __m128 cmplt128_f32(__m128 a, __m128 b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_AVX)
    return _mm_cmp_ps(a, b, _CMP_LT_OQ);
#    else
    return _mm_cmplt_ps(a, b);
#    endif
}

KTM_FUNC __m128 cmpgt128_f32(__m128 a, __m128 b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_AVX)
    return _mm_cmp_ps(a, b, _CMP_GT_OQ);
#    else
    return _mm_cmpgt_ps(a, b);
#    endif
}

KTM_FUNC __m128 cmple128_f32(__m128 a, __m128 b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_AVX)
    return _mm_cmp_ps(a, b, _CMP_LE_OQ);
#    else
    return _mm_cmple_ps(a, b);
#    endif
}

KTM_FUNC __m128 cmpge128_f32(__m128 a, __m128 b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_AVX)
    return _mm_cmp_ps(a, b, _CMP_GE_OQ);
#    else
    return _mm_cmpge_ps(a, b);
#    endif
}

KTM_FUNC __m128 recipl128_f32(__m128 a) noexcept { return _mm_rcp_ps(a); }

KTM_FUNC __m128 reciph128_f32(__m128 a) noexcept
{
    constexpr union
    {
        unsigned int i;
        float f;
    } ninf { 0xff800000 };

    __m128 r = recipl128_f32(a);
    __m128 mask = _mm_cmpeq_ps(a, _mm_setzero_ps());
    __m128 a_sel = _mm_andnot_ps(mask, a);
    __m128 ninf_sel = _mm_and_ps(mask, _mm_set1_ps(ninf.f));
    __m128 mul = _mm_mul_ps(_mm_or_ps(a_sel, ninf_sel), r);
    __m128 sub = _mm_sub_ps(_mm_set1_ps(2.f), mul);
    return _mm_mul_ps(r, sub);
}

KTM_FUNC __m128 rsqrtl128_f32(__m128 a) noexcept { return _mm_rsqrt_ps(a); }

KTM_FUNC __m128 rsqrth128_f32(__m128 a) noexcept
{
    constexpr union
    {
        unsigned int i;
        float f;
    } inf { 0x7f800000 };

    __m128 r = rsqrtl128_f32(a);
    __m128 mask = _mm_cmpeq_ps(r, _mm_set1_ps(inf.f));
    __m128 a_sel = _mm_andnot_ps(mask, a);
    __m128 ninf_sel = _mm_and_ps(mask, _mm_set1_ps(-inf.f));
    __m128 mul = _mm_mul_ps(_mm_mul_ps(_mm_set1_ps(0.5f), _mm_or_ps(a_sel, ninf_sel)), _mm_mul_ps(r, r));
    __m128 sub = _mm_sub_ps(_mm_set1_ps(1.5f), mul);
    return _mm_mul_ps(r, sub);
}

KTM_FUNC __m128 sqrtl128_f32(__m128 a) noexcept { return _mm_rcp_ps(_mm_rsqrt_ps(a)); }

KTM_FUNC __m128 sqrth128_f32(__m128 a) noexcept { return _mm_sqrt_ps(a); }

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_SSE2)

KTM_FUNC __m128i cast128_s32_f32(__m128 a) noexcept { return _mm_castps_si128(a); }

KTM_FUNC __m128 cast128_f32_s32(__m128i a) noexcept { return _mm_castsi128_ps(a); }

KTM_FUNC __m128i dup128_s32(int a) noexcept { return _mm_set1_epi32(a); }

KTM_FUNC __m128i set128_s32(int a, int b, int c, int d) noexcept { return _mm_set_epi32(a, b, c, d); }

KTM_FUNC __m128i add128_s32(__m128i a, __m128i b) noexcept { return _mm_add_epi32(a, b); }

KTM_FUNC __m128i sub128_s32(__m128i a, __m128i b) noexcept { return _mm_sub_epi32(a, b); }

KTM_FUNC __m128i neg128_s32(__m128i a) noexcept { return _mm_sub_epi32(_mm_setzero_si128(), a); }

KTM_FUNC __m128i abs128_s32(__m128i a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_SSSE3)
    return _mm_abs_epi32(a);
#    else
    __m128i mask = _mm_srli_epi32(a, 31);
    return _mm_sub_epi32(_mm_xor_si128(a, mask), mask);
#    endif
}

KTM_FUNC __m128i cmpeq128_s32(__m128i a, __m128i b) noexcept { return _mm_cmpeq_epi32(a, b); }

KTM_FUNC __m128i cmplt128_s32(__m128i a, __m128i b) noexcept { return _mm_cmplt_epi32(a, b); }

KTM_FUNC __m128i cmpgt128_s32(__m128i a, __m128i b) noexcept { return _mm_cmpgt_epi32(a, b); }

KTM_FUNC __m128i cmple128_s32(__m128i a, __m128i b) noexcept
{
    return _mm_xor_si128(_mm_cmpgt_epi32(a, b), _mm_set1_epi32(0xffffffff));
}

KTM_FUNC __m128i cmpge128_s32(__m128i a, __m128i b) noexcept
{
    return _mm_xor_si128(_mm_cmplt_epi32(a, b), _mm_set1_epi32(0xffffffff));
}

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_SSE3)

KTM_FUNC __m128 padd128_f32(__m128 a, __m128 b) noexcept { return _mm_hadd_ps(a, b); }

KTM_FUNC __m128 psub128_f32(__m128 a, __m128 b) noexcept { return _mm_hsub_ps(a, b); }

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_SSSE3)

KTM_FUNC __m128i padd128_s32(__m128i a, __m128i b) noexcept { return _mm_hadd_epi32(a, b); }

KTM_FUNC __m128i psub128_s32(__m128i a, __m128i b) noexcept { return _mm_hsub_epi32(a, b); }

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_SSE4_1)

template <unsigned char DotLane, unsigned char StrLane>
KTM_FUNC __m128 dot128_f32(__m128 a, __m128 b) noexcept
{
    return _mm_dp_ps(a, b, (DotLane << 4) | StrLane);
}

KTM_FUNC __m128 round128_f32(__m128 a) noexcept { return _mm_round_ps(a, _MM_FROUND_TO_NEAREST_INT); }

KTM_FUNC __m128 floor128_f32(__m128 a) noexcept { return _mm_floor_ps(a); }

KTM_FUNC __m128 ceil128_f32(__m128 a) noexcept { return _mm_ceil_ps(a); }

KTM_FUNC __m128i mul128_s32(__m128i a, __m128i b) noexcept { return _mm_mullo_epi32(a, b); }

KTM_FUNC __m128i madd128_s32(__m128i a, __m128i b, __m128i c) noexcept
{
    return _mm_add_epi32(a, _mm_mullo_epi32(b, c));
}

KTM_FUNC __m128i max128_s32(__m128i a, __m128i b) noexcept { return _mm_max_epi32(a, b); }

KTM_FUNC __m128i min128_s32(__m128i a, __m128i b) noexcept { return _mm_min_epi32(a, b); }

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_AVX)

KTM_FUNC __m256 load256_f32(const void* p) noexcept { return _mm256_loadu_ps(reinterpret_cast<const float*>(p)); }

KTM_FUNC void store256_f32(void* p, __m256 a) noexcept { _mm256_storeu_ps(reinterpret_cast<float*>(p), a); }

template <size_t N7, size_t N6, size_t N5, size_t N4, size_t N3, size_t N2, size_t N1, size_t N0>
KTM_FUNC __m256 shuffle256_f32(__m256 a) noexcept
{
    constexpr bool low_idx_in_range_0_3 =
        (N0 >= 0 && N0 < 4) && (N1 >= 0 && N1 < 4) && (N2 >= 0 && N2 < 4) && (N3 >= 0 && N3 < 4);
    constexpr bool high_idx_in_range_4_7 =
        (N4 >= 4 && N4 < 8) && (N5 >= 4 && N5 < 8) && (N6 >= 4 && N6 < 8) && (N7 >= 4 && N7 < 8);
    if constexpr (low_idx_in_range_0_3 && high_idx_in_range_4_7)
    {
        return _mm256_permutevar_ps(a, _mm256_set_epi32(N7 - 4, N6 - 4, N5 - 4, N4 - 4, N3, N2, N1, N0));
    }
    else
    {
#    if KTM_SIMD_ENABLE(KTM_SIMD_AVX2)
        return _mm256_permutevar8x32_ps(a, _mm256_set_epi32(N7, N6, N5, N4, N3, N2, N1, N0));
#    else
        constexpr auto is_continue_idx_lambda = [](size_t n0, size_t n1, size_t n2, size_t n3) -> bool
        {
            return (n0 + 1 == n1) && (n1 + 1 == n2) && (n2 + 1 == n3);
        };
        constexpr bool low_idx_is_m128 = is_continue_idx_lambda(N0, N1, N2, N3) && (N0 == 0 || N0 == 4);
        constexpr bool high_idx_is_m128 = is_continue_idx_lambda(N4, N5, N6, N7) && (N4 == 0 || N4 == 4);
        if constexpr (low_idx_is_m128 && high_idx_is_m128)
        {
            constexpr int permute2f128_mask = (N0 == 0 ? 0 : 1) | ((N4 == 0 ? 0 : 1) << 4);
            return _mm256_permute2f128_ps(a, a, permute2f128_mask);
        }
        else
        {
            __m256i shuff = _mm256_set_epi32(N7 % 4, N6 % 4, N5 % 4, N4 % 4, N3 % 4, N2 % 4, N1 % 4, N0 % 4);
            __m256 shuff_ra = _mm256_permute2f128_ps(a, a, 0x01);
            __m256 shuff_a = _mm256_permutevar_ps(a, shuff);
            shuff_ra = _mm256_permutevar_ps(shuff_ra, shuff);

            constexpr int blend_mask = (N0 >= 4) | ((N1 >= 4) << 1) | ((N2 >= 4) << 2) | ((N3 >= 4) << 3) |
                                       ((N4 < 4) << 4) | ((N5 < 4) << 5) | ((N6 < 4) << 6) | ((N7 < 4) << 7);
            return _mm256_blend_ps(shuff_a, shuff_ra, blend_mask);
        }
#    endif
    }
}

KTM_FUNC __m256 mul256_f32(__m256 a, __m256 b) noexcept { return _mm256_mul_ps(a, b); }

KTM_FUNC __m256 madd256_f32(__m256 a, __m256 b, __m256 c) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_FMA)
    return _mm256_fmadd_ps(b, c, a);
#    else
    return _mm256_add_ps(a, _mm256_mul_ps(b, c));
#    endif
}

KTM_FUNC __m256i cast256_s32_f32(__m256 a) noexcept { return _mm256_castps_si256(a); }

KTM_FUNC __m256 cast256_f32_s32(__m256i a) noexcept { return _mm256_castsi256_ps(a); }

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_AVX2)

KTM_FUNC __m256i mul256_s32(__m256i a, __m256i b) noexcept { return _mm256_mullo_epi32(a, b); }

KTM_FUNC __m256i madd256_s32(__m256i a, __m256i b, __m256i c) noexcept
{
    return _mm256_add_epi32(a, _mm256_mullo_epi32(b, c));
}

#endif

} // namespace intrin

#endif