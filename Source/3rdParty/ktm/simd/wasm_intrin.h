//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_WASM_INTRIN_H_
#define _KTM_WASM_INTRIN_H_

#include "arch_def.h"

namespace intrin
{

#if KTM_SIMD_ENABLE(KTM_SIMD_WASM)

KTM_FUNC float cast128to32_f32(v128_t a) noexcept { return wasm_f32x4_extract_lane(a, 0); }

KTM_FUNC v128_t load128_f32(const void* p) noexcept { return wasm_v128_load(p); }

KTM_FUNC void store128_f32(void* p, v128_t a) noexcept { wasm_v128_store(p, a); }

KTM_FUNC v128_t dup128_f32(float a) noexcept { return wasm_f32x4_splat(a); }

KTM_FUNC v128_t dupzero128_f32() noexcept { return wasm_f32x4_const_splat(0.f); }

KTM_FUNC v128_t set128_f32(float a, float b, float c, float d) noexcept { return wasm_f32x4_make(d, c, b, a); }

template <size_t N3, size_t N2, size_t N1, size_t N0>
KTM_FUNC v128_t shuffle128_f32(v128_t a, v128_t b) noexcept
{
    return wasm_i32x4_shuffle(a, b, N0, N1, N2 + 4, N3 + 4);
}

template <size_t N3, size_t N2, size_t N1, size_t N0>
KTM_FUNC v128_t shuffle128_f32(v128_t a) noexcept
{
    return wasm_i32x4_shuffle(a, a, N0, N1, N2 + 4, N3 + 4);
}

KTM_FUNC v128_t and128_f32(v128_t a, v128_t b) noexcept { return wasm_v128_and(a, b); }

KTM_FUNC v128_t or128_f32(v128_t a, v128_t b) noexcept { return wasm_v128_or(a, b); }

KTM_FUNC v128_t xor128_f32(v128_t a, v128_t b) noexcept { return wasm_v128_xor(a, b); }

KTM_FUNC v128_t add128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_add(a, b); }

KTM_FUNC v128_t sub128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_sub(a, b); }

KTM_FUNC v128_t mul128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_mul(a, b); }

KTM_FUNC v128_t div128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_div(a, b); }

KTM_FUNC v128_t madd128_f32(v128_t a, v128_t b, v128_t c) noexcept { return wasm_f32x4_add(a, wasm_f32x4_mul(b, c)); }

KTM_FUNC v128_t neg128_f32(v128_t a) noexcept { return wasm_f32x4_neg(a); }

KTM_FUNC v128_t abs128_f32(v128_t a) noexcept { return wasm_f32x4_abs(a); }

KTM_FUNC v128_t max128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_max(a, b); }

KTM_FUNC v128_t min128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_min(a, b); }

KTM_FUNC v128_t cmpeq128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_eq(a, b); }

KTM_FUNC v128_t cmplt128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_lt(a, b); }

KTM_FUNC v128_t cmpgt128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_gt(a, b); }

KTM_FUNC v128_t cmple128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_le(a, b); }

KTM_FUNC v128_t cmpge128_f32(v128_t a, v128_t b) noexcept { return wasm_f32x4_ge(a, b); }

KTM_FUNC v128_t recipl128_f32(v128_t a) noexcept
{
    v128_t ret = wasm_i32x4_sub(wasm_i32x4_splat(0x7ef477d5), a);
    v128_t sub = wasm_f32x4_sub(wasm_f32x4_splat(2.f), wasm_f32x4_mul(a, ret));
    ret = wasm_f32x4_mul(ret, sub);
    return ret;
}

KTM_FUNC v128_t reciph128_f32(v128_t a) noexcept { return wasm_f32x4_div(wasm_f32x4_splat(1.f), a); }

KTM_FUNC v128_t rsqrtl128_f32(v128_t a) noexcept
{
    v128_t ret = wasm_i32x4_sub(wasm_i32x4_splat(0x5f3759df), wasm_i32x4_shr(a, 1));
    v128_t mul = wasm_f32x4_mul(wasm_f32x4_splat(0.5f), wasm_f32x4_mul(a, wasm_f32x4_mul(ret, ret)));
    v128_t sub = wasm_f32x4_sub(wasm_f32x4_splat(1.5f), mul);
    ret = wasm_f32x4_mul(ret, sub);
    return ret;
}

KTM_FUNC v128_t rsqrth128_f32(v128_t a) noexcept { return wasm_f32x4_div(wasm_f32x4_splat(1.f), wasm_f32x4_sqrt(a)); }

KTM_FUNC v128_t sqrtl128_f32(v128_t a) noexcept
{
    v128_t ret = wasm_i32x4_add(wasm_i32x4_splat(0x1fbd1df5), wasm_i32x4_shr(a, 1));
    v128_t mul = wasm_f32x4_add(ret, wasm_f32x4_div(a, ret));
    ret = wasm_f32x4_mul(mul, wasm_f32x4_splat(0.5f));
    return ret;
}

KTM_FUNC v128_t sqrth128_f32(v128_t a) noexcept { return wasm_f32x4_sqrt(a); }

KTM_FUNC v128_t round128_f32(v128_t a) noexcept { return wasm_f32x4_nearest(a); }

KTM_FUNC v128_t floor128_f32(v128_t a) noexcept { return wasm_f32x4_floor(a); }

KTM_FUNC v128_t ceil128_f32(v128_t a) noexcept { return wasm_f32x4_ceil(a); }

KTM_FUNC v128_t cast128_s32_f32(v128_t a) noexcept { return a; }

KTM_FUNC v128_t cast128_f32_s32(v128_t a) noexcept { return a; }

KTM_FUNC v128_t dup128_s32(int a) noexcept { return wasm_i32x4_splat(a); }

KTM_FUNC v128_t set128_s32(int a, int b, int c, int d) noexcept { return wasm_i32x4_make(d, c, b, a); }

KTM_FUNC v128_t add128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_add(a, b); }

KTM_FUNC v128_t sub128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_sub(a, b); }

KTM_FUNC v128_t mul128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_mul(a, b); }

KTM_FUNC v128_t neg128_s32(v128_t a) noexcept { return wasm_i32x4_neg(a); }

KTM_FUNC v128_t abs128_s32(v128_t a) noexcept { return wasm_i32x4_abs(a); }

KTM_FUNC v128_t cmpeq128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_eq(a, b); }

KTM_FUNC v128_t cmplt128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_lt(a, b); }

KTM_FUNC v128_t cmpgt128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_gt(a, b); }

KTM_FUNC v128_t cmple128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_le(a, b); }

KTM_FUNC v128_t cmpge128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_ge(a, b); }

KTM_FUNC v128_t madd128_s32(v128_t a, v128_t b, v128_t c) noexcept { return wasm_i32x4_add(a, wasm_i32x4_mul(b, c)); }

KTM_FUNC v128_t max128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_max(a, b); }

KTM_FUNC v128_t min128_s32(v128_t a, v128_t b) noexcept { return wasm_i32x4_min(a, b); }

#endif

} // namespace intrin

#endif