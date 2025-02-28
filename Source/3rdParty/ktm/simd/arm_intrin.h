//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_ARM_INTRIN_H_
#define _KTM_ARM_INTRIN_H_

#include "arch_def.h"

namespace intrin
{

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

KTM_FUNC float cast64to32_f32(float32x2_t a) noexcept { return vget_lane_f32(a, 0); }

KTM_FUNC int32x2_t cast64_s32_f32(float32x2_t a) noexcept { return vreinterpret_s32_f32(a); }

KTM_FUNC float32x2_t cast64_f32_s32(int32x2_t a) noexcept { return vreinterpret_f32_s32(a); }

KTM_FUNC float32x2_t load64_f32(const void* p) noexcept { return vld1_f32(reinterpret_cast<const float*>(p)); }

KTM_FUNC void store64_f32(void* p, float32x2_t a) noexcept { vst1_f32(reinterpret_cast<float*>(p), a); }

KTM_FUNC float32x2_t dup64_f32(float a) noexcept { return vdup_n_f32(a); }

KTM_FUNC float32x2_t dupzero64_f32() noexcept { return vdup_n_f32(0.f); }

KTM_FUNC float32x2_t set64_f32(float a, float b) noexcept
{
    float32x2_t ret = vmov_n_f32(b);
    return vset_lane_f32(a, ret, 1);
}

template <size_t N1, size_t N0>
KTM_FUNC float32x2_t shuffle64_f32(float32x2_t a, float32x2_t b) noexcept
{
#    if defined(KTM_COMPILER_CLANG)
#        if defined(__ORDER_LITTLE_ENDIAN__)
    return __builtin_shufflevector(a, b, N0, N1 + 2);
#        else
    return __builtin_shufflevector(b, a, 1 - N1, 3 - N0);
#        endif
#    elif defined(KTM_COMPILER_GCC)
#        if defined(__ORDER_LITTLE_ENDIAN__)
    return __builtin_shuffle(a, b, uint32x2_t { N0, N1 + 2 });
#        else
    return __builtin_shuffle(b, a, uint32x2_t { 1 - N1, 3 - N0 });
#        endif
#    else
    float32x2_t ret = vmov_n_f32(vget_lane_f32(a, N0));
    return vset_lane_f32(vget_lane_f32(b, N1), ret, 1);
#    endif
}

template <size_t N1, size_t N0>
KTM_FUNC float32x2_t shuffle64_f32(float32x2_t a) noexcept
{
    return shuffle64_f32<N1, N0>(a, a);
}

KTM_FUNC float32x2_t and64_f32(float32x2_t a, float32x2_t b) noexcept
{
    return vreinterpret_f32_u32(vand_u32(vreinterpret_u32_f32(a), vreinterpret_u32_f32(b)));
}

KTM_FUNC float32x2_t or64_f32(float32x2_t a, float32x2_t b) noexcept
{
    return vreinterpret_f32_u32(vorr_u32(vreinterpret_u32_f32(a), vreinterpret_u32_f32(b)));
}

KTM_FUNC float32x2_t xor64_f32(float32x2_t a, float32x2_t b) noexcept
{
    return vreinterpret_f32_u32(veor_u32(vreinterpret_u32_f32(a), vreinterpret_u32_f32(b)));
}

KTM_FUNC float32x2_t add64_f32(float32x2_t a, float32x2_t b) noexcept { return vadd_f32(a, b); }

KTM_FUNC float32x2_t sub64_f32(float32x2_t a, float32x2_t b) noexcept { return vsub_f32(a, b); }

KTM_FUNC float32x2_t mul64_f32(float32x2_t a, float32x2_t b) noexcept { return vmul_f32(a, b); }

KTM_FUNC float32x2_t madd64_f32(float32x2_t a, float32x2_t b, float32x2_t c) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vfma_f32(a, b, c);
#    else
    return vmla_f32(a, b, c);
#    endif
}

KTM_FUNC float32x2_t neg64_f32(float32x2_t a) noexcept { return vneg_f32(a); }

KTM_FUNC float32x2_t abs64_f32(float32x2_t a) noexcept { return vabs_f32(a); }

KTM_FUNC float32x2_t max64_f32(float32x2_t a, float32x2_t b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vmaxnm_f32(a, b);
#    else
    return vmax_f32(a, b);
#    endif
}

KTM_FUNC float32x2_t min64_f32(float32x2_t a, float32x2_t b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vminnm_f32(a, b);
#    else
    return vmin_f32(a, b);
#    endif
}

KTM_FUNC float32x2_t cmpeq64_f32(float32x2_t a, float32x2_t b) noexcept { return vreinterpret_f32_u32(vceq_f32(a, b)); }

KTM_FUNC float32x2_t cmplt64_f32(float32x2_t a, float32x2_t b) noexcept { return vreinterpret_f32_u32(vclt_f32(a, b)); }

KTM_FUNC float32x2_t cmpgt64_f32(float32x2_t a, float32x2_t b) noexcept { return vreinterpret_f32_u32(vcgt_f32(a, b)); }

KTM_FUNC float32x2_t cmple64_f32(float32x2_t a, float32x2_t b) noexcept { return vreinterpret_f32_u32(vcle_f32(a, b)); }

KTM_FUNC float32x2_t cmpge64_f32(float32x2_t a, float32x2_t b) noexcept { return vreinterpret_f32_u32(vcge_f32(a, b)); }

KTM_FUNC float32x2_t recipl64_f32(float32x2_t a) noexcept { return vrecpe_f32(a); }

KTM_FUNC float32x2_t reciph64_f32(float32x2_t a) noexcept
{
    float32x2_t r = recipl64_f32(a);
    r = vmul_f32(r, vrecps_f32(a, r));
    r = vmul_f32(r, vrecps_f32(a, r));
    return r;
}

KTM_FUNC float32x2_t rsqrtl64_f32(float32x2_t a) noexcept { return vrsqrte_f32(a); }

KTM_FUNC float32x2_t rsqrth64_f32(float32x2_t a) noexcept
{
    float32x2_t r = rsqrtl64_f32(a);
    r = vmul_f32(r, vrsqrts_f32(a, vmul_f32(r, r)));
    r = vmul_f32(r, vrsqrts_f32(a, vmul_f32(r, r)));
    return r;
}

KTM_FUNC float32x2_t sqrtl64_f32(float32x2_t a) noexcept { return vrecpe_f32(vrsqrte_f32(a)); }

KTM_FUNC float32x2_t sqrth64_f32(float32x2_t a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vsqrt_f32(a);
#    else
    return reciph64_f32(rsqrth64_f32(a));
#    endif
}

KTM_FUNC float32x2_t div64_f32(float32x2_t a, float32x2_t b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vdiv_f32(a, b);
#    else
    return vmul_f32(a, reciph64_f32(b));
#    endif
}

KTM_FUNC float cast128to32_f32(float32x4_t a) noexcept { return vgetq_lane_f32(a, 0); }

KTM_FUNC float32x2_t cast128to64_f32(float32x4_t a) noexcept { return vget_low_f32(a); }

KTM_FUNC int32x4_t cast128_s32_f32(float32x4_t a) noexcept { return vreinterpretq_s32_f32(a); }

KTM_FUNC float32x4_t cast128_f32_s32(int32x4_t a) noexcept { return vreinterpretq_f32_s32(a); }

KTM_FUNC float32x4_t load128_f32(const void* p) noexcept { return vld1q_f32(reinterpret_cast<const float*>(p)); }

KTM_FUNC void store128_f32(void* p, float32x4_t a) noexcept { vst1q_f32(reinterpret_cast<float*>(p), a); }

KTM_FUNC float32x4_t dup128_f32(float a) noexcept { return vdupq_n_f32(a); }

KTM_FUNC float32x4_t dupzero128_f32() noexcept { return vdupq_n_f32(0.f); }

KTM_FUNC float32x4_t set128_f32(float a, float b, float c, float d) noexcept
{
    float32x4_t ret = vmovq_n_f32(d);
    ret = vsetq_lane_f32(c, ret, 1);
    ret = vsetq_lane_f32(b, ret, 2);
    ret = vsetq_lane_f32(a, ret, 3);
    return ret;
}

template <size_t N3, size_t N2, size_t N1, size_t N0>
KTM_FUNC float32x4_t shuffle128_f32(float32x4_t a, float32x4_t b) noexcept
{
#    if defined(KTM_COMPILER_CLANG)
#        if defined(__ORDER_LITTLE_ENDIAN__)
    return __builtin_shufflevector(a, b, N0, N1, N2 + 4, N3 + 4);
#        else
    return __builtin_shufflevector(b, a, 3 - N3, 3 - N2, 7 - N1, 7 - N0);
#        endif
#    elif defined(KTM_COMPILER_GCC)
#        if defined(__ORDER_LITTLE_ENDIAN__)
    return __builtin_shuffle(a, b, uint32x4_t { N0, N1, N2 + 4, N3 + 4 });
#        else
    return __builtin_shuffle(b, a, uint32x4_t { 3 - N3, 3 - N2, 7 - N1, 7 - N0 });
#        endif
#    else
    float32x4_t ret = vmovq_n_f32(vgetq_lane_f32(a, N0));
    ret = vsetq_lane_f32(vgetq_lane_f32(a, N1), ret, 1);
    ret = vsetq_lane_f32(vgetq_lane_f32(b, N2), ret, 2);
    ret = vsetq_lane_f32(vgetq_lane_f32(b, N3), ret, 3);
    return ret;
#    endif
}

template <size_t N3, size_t N2, size_t N1, size_t N0>
KTM_FUNC float32x4_t shuffle128_f32(float32x4_t a) noexcept
{
    return shuffle128_f32<N3, N2, N1, N0>(a, a);
}

KTM_FUNC float32x4_t and128_f32(float32x4_t a, float32x4_t b) noexcept
{
    return vreinterpretq_f32_u32(vandq_u32(vreinterpretq_u32_f32(a), vreinterpretq_u32_f32(b)));
}

KTM_FUNC float32x4_t or128_f32(float32x4_t a, float32x4_t b) noexcept
{
    return vreinterpretq_f32_u32(vorrq_u32(vreinterpretq_u32_f32(a), vreinterpretq_u32_f32(b)));
}

KTM_FUNC float32x4_t xor128_f32(float32x4_t a, float32x4_t b) noexcept
{
    return vreinterpretq_f32_u32(veorq_u32(vreinterpretq_u32_f32(a), vreinterpretq_u32_f32(b)));
}

KTM_FUNC float32x4_t add128_f32(float32x4_t a, float32x4_t b) noexcept { return vaddq_f32(a, b); }

KTM_FUNC float32x4_t sub128_f32(float32x4_t a, float32x4_t b) noexcept { return vsubq_f32(a, b); }

KTM_FUNC float32x4_t mul128_f32(float32x4_t a, float32x4_t b) noexcept { return vmulq_f32(a, b); }

KTM_FUNC float32x4_t madd128_f32(float32x4_t a, float32x4_t b, float32x4_t c) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vfmaq_f32(a, b, c);
#    else
    return vmlaq_f32(a, b, c);
#    endif
}

KTM_FUNC float32x4_t neg128_f32(float32x4_t a) noexcept { return vnegq_f32(a); }

KTM_FUNC float32x4_t abs128_f32(float32x4_t a) noexcept { return vabsq_f32(a); }

KTM_FUNC float32x4_t max128_f32(float32x4_t a, float32x4_t b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vmaxnmq_f32(a, b);
#    else
    return vmaxq_f32(a, b);
#    endif
}

KTM_FUNC float32x4_t min128_f32(float32x4_t a, float32x4_t b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vminnmq_f32(a, b);
#    else
    return vminq_f32(a, b);
#    endif
}

KTM_FUNC float32x4_t cmpeq128_f32(float32x4_t a, float32x4_t b) noexcept
{
    return vreinterpretq_f32_u32(vceqq_f32(a, b));
}

KTM_FUNC float32x4_t cmplt128_f32(float32x4_t a, float32x4_t b) noexcept
{
    return vreinterpretq_f32_u32(vcltq_f32(a, b));
}

KTM_FUNC float32x4_t cmpgt128_f32(float32x4_t a, float32x4_t b) noexcept
{
    return vreinterpretq_f32_u32(vcgtq_f32(a, b));
}

KTM_FUNC float32x4_t cmple128_f32(float32x4_t a, float32x4_t b) noexcept
{
    return vreinterpretq_f32_u32(vcleq_f32(a, b));
}

KTM_FUNC float32x4_t cmpge128_f32(float32x4_t a, float32x4_t b) noexcept
{
    return vreinterpretq_f32_u32(vcgeq_f32(a, b));
}

KTM_FUNC float32x4_t recipl128_f32(float32x4_t a) noexcept { return vrecpeq_f32(a); }

KTM_FUNC float32x4_t reciph128_f32(float32x4_t a) noexcept
{
    float32x4_t r = recipl128_f32(a);
    r = vmulq_f32(r, vrecpsq_f32(a, r));
    r = vmulq_f32(r, vrecpsq_f32(a, r));
    return r;
}

KTM_FUNC float32x4_t rsqrtl128_f32(float32x4_t a) noexcept { return vrsqrteq_f32(a); }

KTM_FUNC float32x4_t rsqrth128_f32(float32x4_t a) noexcept
{
    float32x4_t r = rsqrtl128_f32(a);
    r = vmulq_f32(r, vrsqrtsq_f32(a, vmulq_f32(r, r)));
    r = vmulq_f32(r, vrsqrtsq_f32(a, vmulq_f32(r, r)));
    return r;
}

KTM_FUNC float32x4_t sqrtl128_f32(float32x4_t a) noexcept { return vrecpeq_f32(vrsqrteq_f32(a)); }

KTM_FUNC float32x4_t sqrth128_f32(float32x4_t a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vsqrtq_f32(a);
#    else
    return reciph128_f32(rsqrth128_f32(a));
#    endif
}

KTM_FUNC float32x4_t div128_f32(float32x4_t a, float32x4_t b) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return vdivq_f32(a, b);
#    else
    return vmulq_f32(a, reciph128_f32(b));
#    endif
}

KTM_FUNC int32x2_t dup64_s32(int a) noexcept { return vdup_n_s32(a); }

KTM_FUNC int32x2_t set64_s32(int a, int b) noexcept
{
    int32x2_t ret = vmov_n_s32(b);
    return vset_lane_s32(a, ret, 1);
}

KTM_FUNC int32x2_t add64_s32(int32x2_t a, int32x2_t b) noexcept { return vadd_s32(a, b); }

KTM_FUNC int32x2_t sub64_s32(int32x2_t a, int32x2_t b) noexcept { return vsub_s32(a, b); }

KTM_FUNC int32x2_t mul64_s32(int32x2_t a, int32x2_t b) noexcept { return vmul_s32(a, b); }

KTM_FUNC int32x2_t madd64_s32(int32x2_t a, int32x2_t b, int32x2_t c) noexcept { return vmla_s32(a, b, c); }

KTM_FUNC int32x2_t neg64_s32(int32x2_t a) noexcept { return vneg_s32(a); }

KTM_FUNC int32x2_t abs64_s32(int32x2_t a) noexcept { return vabs_s32(a); }

KTM_FUNC int32x2_t max64_s32(int32x2_t a, int32x2_t b) noexcept { return vmax_s32(a, b); }

KTM_FUNC int32x2_t min64_s32(int32x2_t a, int32x2_t b) noexcept { return vmin_s32(a, b); }

KTM_FUNC int32x2_t cmpeq64_s32(int32x2_t a, int32x2_t b) noexcept { return vreinterpret_s32_u32(vceq_s32(a, b)); }

KTM_FUNC int32x2_t cmplt64_s32(int32x2_t a, int32x2_t b) noexcept { return vreinterpret_s32_u32(vclt_s32(a, b)); }

KTM_FUNC int32x2_t cmpgt64_s32(int32x2_t a, int32x2_t b) noexcept { return vreinterpret_s32_u32(vcgt_s32(a, b)); }

KTM_FUNC int32x2_t cmple64_s32(int32x2_t a, int32x2_t b) noexcept { return vreinterpret_s32_u32(vcle_s32(a, b)); }

KTM_FUNC int32x2_t cmpge64_s32(int32x2_t a, int32x2_t b) noexcept { return vreinterpret_s32_u32(vcge_s32(a, b)); }

KTM_FUNC int32x4_t dup128_s32(int a) noexcept { return vdupq_n_s32(a); }

KTM_FUNC int32x4_t set128_s32(int a, int b, int c, int d) noexcept
{
    int32x4_t ret = vmovq_n_s32(d);
    ret = vsetq_lane_s32(c, ret, 1);
    ret = vsetq_lane_s32(b, ret, 2);
    ret = vsetq_lane_s32(a, ret, 3);
    return ret;
}

KTM_FUNC int32x4_t add128_s32(int32x4_t a, int32x4_t b) noexcept { return vaddq_s32(a, b); }

KTM_FUNC int32x4_t sub128_s32(int32x4_t a, int32x4_t b) noexcept { return vsubq_s32(a, b); }

KTM_FUNC int32x4_t mul128_s32(int32x4_t a, int32x4_t b) noexcept { return vmulq_s32(a, b); }

KTM_FUNC int32x4_t madd128_s32(int32x4_t a, int32x4_t b, int32x4_t c) noexcept { return vmlaq_s32(a, b, c); }

KTM_FUNC int32x4_t neg128_s32(int32x4_t a) noexcept { return vnegq_s32(a); }

KTM_FUNC int32x4_t abs128_s32(int32x4_t a) noexcept { return vabsq_s32(a); }

KTM_FUNC int32x4_t max128_s32(int32x4_t a, int32x4_t b) noexcept { return vmaxq_s32(a, b); }

KTM_FUNC int32x4_t min128_s32(int32x4_t a, int32x4_t b) noexcept { return vminq_s32(a, b); }

KTM_FUNC int32x4_t cmpeq128_s32(int32x4_t a, int32x4_t b) noexcept { return vreinterpretq_s32_u32(vceqq_s32(a, b)); }

KTM_FUNC int32x4_t cmplt128_s32(int32x4_t a, int32x4_t b) noexcept { return vreinterpretq_s32_u32(vcltq_s32(a, b)); }

KTM_FUNC int32x4_t cmpgt128_s32(int32x4_t a, int32x4_t b) noexcept { return vreinterpretq_s32_u32(vcgtq_s32(a, b)); }

KTM_FUNC int32x4_t cmple128_s32(int32x4_t a, int32x4_t b) noexcept { return vreinterpretq_s32_u32(vcleq_s32(a, b)); }

KTM_FUNC int32x4_t cmpge128_s32(int32x4_t a, int32x4_t b) noexcept { return vreinterpretq_s32_u32(vcgeq_s32(a, b)); }

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)

KTM_FUNC float32x2_t padd64_f32(float32x2_t a, float32x2_t b) noexcept { return vpadd_f32(a, b); }

KTM_FUNC float32x2_t round64_f32(float32x2_t a) noexcept { return vrndi_f32(a); }

KTM_FUNC float32x2_t floor64_f32(float32x2_t a) noexcept { return vrndm_f32(a); }

KTM_FUNC float32x2_t ceil64_f32(float32x2_t a) noexcept { return vrndp_f32(a); }

KTM_FUNC float32x4_t padd128_f32(float32x4_t a, float32x4_t b) noexcept { return vpaddq_f32(a, b); }

KTM_FUNC float radd128_f32(float32x4_t a) noexcept { return vaddvq_f32(a); }

KTM_FUNC float rmax128_f32(float32x4_t a) noexcept { return vmaxvq_f32(a); }

KTM_FUNC float rmin128_f32(float32x4_t a) noexcept { return vminvq_f32(a); }

KTM_FUNC float32x4_t round128_f32(float32x4_t a) noexcept { return vrndiq_f32(a); }

KTM_FUNC float32x4_t floor128_f32(float32x4_t a) noexcept { return vrndmq_f32(a); }

KTM_FUNC float32x4_t ceil128_f32(float32x4_t a) noexcept { return vrndpq_f32(a); }

KTM_FUNC int32x2_t padd64_s32(int32x2_t a, int32x2_t b) noexcept { return vpadd_s32(a, b); }

KTM_FUNC int32x4_t padd128_s32(int32x4_t a, int32x4_t b) noexcept { return vpaddq_s32(a, b); }

KTM_FUNC int radd128_s32(int32x4_t a) noexcept { return vaddvq_s32(a); }

KTM_FUNC int rmax128_s32(int32x4_t a) noexcept { return vmaxvq_s32(a); }

KTM_FUNC int rmin128_s32(int32x4_t a) noexcept { return vminvq_s32(a); }

#endif

} // namespace intrin

#endif