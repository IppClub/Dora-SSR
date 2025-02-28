//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_SKV_H_
#define _KTM_SKV_H_

#include "arch_def.h"
#include "intrin_api.h"

namespace skv
{

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)
typedef float32x2_t fv2;
typedef int32x2_t sv2;
typedef float32x4_t fv4;
typedef int32x4_t sv4;
#elif KTM_SIMD_ENABLE(KTM_SIMD_SSE)
typedef __m128 fv4;
#    if KTM_SIMD_ENABLE(KTM_SIMD_SSE2)
typedef __m128i sv4;
#    endif
#    if KTM_SIMD_ENABLE(KTM_SIMD_AVX)
typedef __m256 fv8;
typedef __m256i sv8;
#    endif
#elif KTM_SIMD_ENABLE(KTM_SIMD_WASM)
typedef v128_t fv4;
typedef v128_t sv4;
#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

KTM_FUNC fv2 round_fv2(fv2 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _round64_f32(a);
#    else
    constexpr union
    {
        unsigned int i;
        float f;
    } mask1 { 0x80000000 };

    constexpr union
    {
        unsigned int i;
        float f;
    } mask2 { 0x4b000000 };

    fv2 tmp = _and64_f32(a, _dup64_f32(mask1.f));
    tmp = _or64_f32(tmp, _dup64_f32(mask2.f));
    fv2 ret = _sub64_f32(_add64_f32(a, tmp), tmp);
    return ret;
#    endif
}

KTM_FUNC fv2 floor_fv2(fv2 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _floor64_f32(a);
#    else
    constexpr union
    {
        unsigned int i;
        float f;
    } mask = { 0x3f800000 };

    fv2 rnd = round_fv2(a);
    fv2 tmp = _cmplt64_f32(a, rnd);
    tmp = _and64_f32(tmp, _dup64_f32(mask.f));
    fv2 ret = _sub64_f32(rnd, tmp);
    return ret;
#    endif
}

KTM_FUNC fv2 ceil_fv2(fv2 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _ceil64_f32(a);
#    else
    constexpr union
    {
        unsigned int i;
        float f;
    } mask = { 0x3f800000 };

    fv2 rnd = round_fv2(a);
    fv2 tmp = _cmpgt64_f32(a, rnd);
    tmp = _and64_f32(tmp, _dup64_f32(mask.f));
    fv2 ret = _add64_f32(rnd, tmp);
    return ret;
#    endif
}

KTM_FUNC float radd_fv2(fv2 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    fv2 add = _padd64_f32(a, a);
#    else
    fv2 add = _add64_f32(a, _shuffo64_f32(a, 0, 1));
#    endif
    return _cast64to32_f32(add);
}

KTM_FUNC int radd_sv2(sv2 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    sv2 add = _padd64_s32(a, a);
#    else
    sv2 add = _add64_s32(a, _cast64_s32_f32(_shuffo64_f32(_cast64_f32_s32(a), 0, 1)));
#    endif
    union
    {
        float f;
        int i;
    } ret { _cast64to32_f32(_cast64_f32_s32(add)) };

    return ret.i;
}

KTM_FUNC fv2 dot_fv2(fv2 x, fv2 y) noexcept
{
    fv2 mul = _mul64_f32(x, y);
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    fv2 dot = _padd64_f32(mul, mul);
#    else
    fv2 dot = _add64_f32(mul, _shuffo64_f32(mul, 0, 1));
#    endif
    return dot;
}

KTM_FUNC fv2 dot1_fv2(fv2 x, fv2 y) noexcept
{
    fv2 mul = _mul64_f32(x, y);
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    fv2 dot = _padd64_f32(mul, mul);
#    else
    fv2 dot = _add64_f32(mul, _shuffo64_f32(mul, 1, 1));
#    endif
    return dot;
}

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

KTM_FUNC fv4 round_fv4(fv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64 | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)
    return _round128_f32(a);
#    else
    constexpr union
    {
        unsigned int i;
        float f;
    } mask1 { 0x80000000 };

    constexpr union
    {
        unsigned int i;
        float f;
    } mask2 { 0x4b000000 };

    fv4 tmp = _and128_f32(a, _dup128_f32(mask1.f));
    tmp = _or128_f32(tmp, _dup128_f32(mask2.f));
    fv4 ret = _sub128_f32(_add128_f32(a, tmp), tmp);
    return ret;
#    endif
}

KTM_FUNC fv4 floor_fv4(fv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64 | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)
    return _floor128_f32(a);
#    else
    constexpr union
    {
        unsigned int i;
        float f;
    } mask = { 0x3f800000 };

    fv4 rnd = round_fv4(a);
    fv4 tmp = _cmplt128_f32(a, rnd);
    tmp = _and128_f32(tmp, _dup128_f32(mask.f));
    fv4 ret = _sub128_f32(rnd, tmp);
    return ret;
#    endif
}

KTM_FUNC fv4 ceil_fv4(fv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64 | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)
    return _ceil128_f32(a);
#    else
    constexpr union
    {
        unsigned int i;
        float f;
    } mask = { 0x3f800000 };

    fv4 rnd = round_fv4(a);
    fv4 tmp = _cmpgt128_f32(a, rnd);
    tmp = _and128_f32(tmp, _dup128_f32(mask.f));
    fv4 ret = _add128_f32(rnd, tmp);
    return ret;
#    endif
}

KTM_FUNC float radd_fv3(fv4 a) noexcept
{
    fv4 shuf = _shuffo128_f32(a, 1, 1, 1, 1);
    fv4 add = _add128_f32(a, shuf);
    shuf = _shuffo128_f32(a, 2, 2, 2, 2);
    add = _add128_f32(add, shuf);
    return _cast128to32_f32(add);
}

KTM_FUNC float radd_fv4(fv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _radd128_f32(a);
#    elif KTM_SIMD_ENABLE(KTM_SIMD_SSE3)
    fv4 add = _padd128_f32(a, a);
    add = _padd128_f32(add, add);
    return _cast128to32_f32(add);
#    else
    fv4 shuf = _shuffo128_f32(a, 2, 3, 0, 1);
    fv4 add = _add128_f32(a, shuf);
    shuf = _shuffo128_f32(add, 1, 0, 3, 2);
    add = _add128_f32(add, shuf);
    return _cast128to32_f32(add);
#    endif
}

KTM_FUNC float rsub_fv4(fv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_SSSE3)
    fv4 sub = _psub128_f32(a, a);
    fv4 add = _padd128_f32(sub, sub);
    return _cast128to32_f32(add);
#    else
    fv4 shuf = _shuffo128_f32(a, 2, 3, 0, 1);
    fv4 sub = _sub128_f32(a, shuf);
    shuf = _shuffo128_f32(sub, 1, 0, 3, 2);
    fv4 add = _add128_f32(sub, shuf);
    return _cast128to32_f32(add);
#    endif
}

KTM_FUNC float rmax_fv4(fv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _rmax128_f32(a);
#    else
    fv4 shuf = _shuffo128_f32(a, 2, 3, 0, 1);
    fv4 max = _max128_f32(a, shuf);
    shuf = _shuffo128_f32(max, 1, 0, 3, 2);
    max = _max128_f32(max, shuf);
    return _cast128to32_f32(max);
#    endif
}

KTM_FUNC float rmin_fv4(fv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _rmin128_f32(a);
#    else
    fv4 shuf = _shuffo128_f32(a, 2, 3, 0, 1);
    fv4 min = _min128_f32(a, shuf);
    shuf = _shuffo128_f32(min, 1, 0, 3, 2);
    min = _min128_f32(min, shuf);
    return _cast128to32_f32(min);
#    endif
}

KTM_FUNC fv4 dot_fv3(fv4 x, fv4 y) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_SSE4_1)
    fv4 dot = _dot128_f32(x, y, 0x7, 0xf);
#    else
    fv4 mul = _mul128_f32(x, y);
    fv4 dot = _add128_f32(_shuffo128_f32(mul, 0, 0, 0, 0), _shuffo128_f32(mul, 1, 1, 1, 1));
    dot = _add128_f32(dot, _shuffo128_f32(mul, 2, 2, 2, 2));
#    endif
    return dot;
}

KTM_FUNC fv4 dot_fv4(fv4 x, fv4 y) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_SSE4_1)
    fv4 dot = _dot128_f32(x, y, 0xf, 0xf);
#    elif KTM_SIMD_ENABLE(KTM_SIMD_NEON64 | KTM_SIMD_SSE3)
    fv4 mul = _mul128_f32(x, y);
    fv4 dot = _padd128_f32(mul, mul);
    dot = _padd128_f32(dot, dot);
#    else
    fv4 mul = _mul128_f32(x, y);
    fv4 dot = _add128_f32(mul, _shuffo128_f32(mul, 2, 3, 0, 1));
    dot = _add128_f32(dot, _shuffo128_f32(dot, 1, 0, 3, 2));
#    endif
    return dot;
}

KTM_FUNC fv4 dot1_fv3(fv4 x, fv4 y) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_SSE4_1)
    fv4 dot = _dot128_f32(x, y, 0x7, 0x1);
#    else
    fv4 mul = _mul128_f32(x, y);
    fv4 dot = _add128_f32(mul, _shuffo128_f32(mul, 1, 1, 1, 1));
    dot = _add128_f32(dot, _shuffo128_f32(mul, 2, 2, 2, 2));
#    endif
    return dot;
}

KTM_FUNC fv4 dot1_fv4(fv4 x, fv4 y) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_SSE4_1)
    fv4 dot = _dot128_f32(x, y, 0xf, 0x1);
#    elif KTM_SIMD_ENABLE(KTM_SIMD_NEON64 | KTM_SIMD_SSE3)
    fv4 mul = _mul128_f32(x, y);
    fv4 dot = _padd128_f32(mul, mul);
    dot = _padd128_f32(dot, dot);
#    else
    fv4 mul = _mul128_f32(x, y);
    fv4 dot = _add128_f32(mul, _shuffo128_f32(mul, 1, 0, 3, 2));
    dot = _add128_f32(dot, _shuffo128_f32(dot, 1, 1, 1, 1));
#    endif
    return dot;
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

KTM_FUNC int radd_sv3(sv4 a) noexcept
{
    sv4 shuf = _shuffo128_s32(a, 1, 1, 1, 1);
    sv4 add = _add128_s32(a, shuf);
    shuf = _shuffo128_s32(add, 2, 2, 2, 2);
    add = _add128_s32(add, shuf);

    union
    {
        float f;
        int i;
    } ret { _cast128to32_f32(_cast128_f32_s32(add)) };

    return ret.i;
}

KTM_FUNC int radd_sv4(sv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _radd128_s32(a);
#    elif KTM_SIMD_ENABLE(KTM_SIMD_SSSE3)
    sv4 add = _padd128_s32(a, a);
    add = _padd128_s32(add, add);

    union
    {
        float f;
        int i;
    } ret { _cast128to32_f32(_cast128_f32_s32(add)) };

    return ret.i;
#    else
    sv4 shuf = _shuffo128_s32(a, 2, 3, 0, 1);
    sv4 add = _add128_s32(a, shuf);
    shuf = _shuffo128_s32(add, 1, 0, 3, 2);
    add = _add128_s32(add, shuf);

    union
    {
        float f;
        int i;
    } ret { _cast128to32_f32(_cast128_f32_s32(add)) };

    return ret.i;
#    endif
}

KTM_FUNC int rsub_sv4(sv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_SSSE3)
    sv4 sub = _psub128_s32(a, a);
    sv4 add = _padd128_s32(sub, sub);
#    else
    sv4 shuf = _shuffo128_s32(a, 2, 3, 0, 1);
    sv4 sub = _sub128_s32(a, shuf);
    shuf = _shuffo128_s32(sub, 1, 0, 3, 2);
    sv4 add = _add128_s32(sub, shuf);
#    endif
    union
    {
        float f;
        int i;
    } ret { _cast128to32_f32(_cast128_f32_s32(add)) };

    return ret.i;
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

KTM_FUNC int rmax_sv4(sv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _rmax128_s32(a);
#    else
    sv4 shuf = _shuffo128_s32(a, 2, 3, 0, 1);
    sv4 max = _max128_s32(a, shuf);
    shuf = _shuffo128_s32(max, 1, 0, 3, 2);
    max = _max128_s32(max, shuf);

    union
    {
        float f;
        int i;
    } ret { _cast128to32_f32(_cast128_f32_s32(max)) };

    return ret.i;
#    endif
}

KTM_FUNC int rmin_sv4(sv4 a) noexcept
{
#    if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)
    return _rmin128_s32(a);
#    else
    sv4 shuf = _shuffo128_s32(a, 2, 3, 0, 1);
    sv4 min = _min128_s32(a, shuf);
    shuf = _shuffo128_s32(min, 1, 0, 3, 2);
    min = _min128_s32(min, shuf);

    union
    {
        float f;
        int i;
    } ret { _cast128to32_f32(_cast128_f32_s32(min)) };

    return ret.i;
#    endif
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

} // namespace skv

#endif