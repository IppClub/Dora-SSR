//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_INTRIN_API_H_
#define _KTM_INTRIN_API_H_

#include "arch_def.h"
#include "arm_intrin.h"
#include "x86_intrin.h"
#include "wasm_intrin.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON)

#    define _load64_f32(p) ::intrin::load64_f32(p)
#    define _store64_f32(p, a) ::intrin::store64_f32(p, a)
#    define _dup64_f32(a) ::intrin::dup64_f32(a)
#    define _dupzero64_f32() ::intrin::dupzero64_f32()
#    define _set64_f32(a, b) ::intrin::set64_f32(a, b)
#    define _shufft64_f32(a, b, n1, n0) ::intrin::shuffle64_f32<n1, n0>(a, b)
#    define _shuffo64_f32(a, n1, n0) ::intrin::shuffle64_f32<n1, n0>(a)
#    define _and64_f32(a, b) ::intrin::and64_f32(a, b)
#    define _or64_f32(a, b) ::intrin::or64_f32(a, b)
#    define _xor64_f32(a, b) ::intrin::xor64_f32(a, b)
#    define _add64_f32(a, b) ::intrin::add64_f32(a, b)
#    define _sub64_f32(a, b) ::intrin::sub64_f32(a, b)
#    define _mul64_f32(a, b) ::intrin::mul64_f32(a, b)
#    define _div64_f32(a, b) ::intrin::div64_f32(a, b)
#    define _madd64_f32(a, b, c) ::intrin::madd64_f32(a, b, c)
#    define _neg64_f32(a) ::intrin::neg64_f32(a)
#    define _abs64_f32(a) ::intrin::abs64_f32(a)
#    define _max64_f32(a, b) ::intrin::max64_f32(a, b)
#    define _min64_f32(a, b) ::intrin::min64_f32(a, b)
#    define _clamp64_f32(a, min, max) _min64_f32(_max64_f32(a, min), max)
#    define _cmpeq64_f32(a, b) ::intrin::cmpeq64_f32(a, b)
#    define _cmplt64_f32(a, b) ::intrin::cmplt64_f32(a, b)
#    define _cmpgt64_f32(a, b) ::intrin::cmpgt64_f32(a, b)
#    define _cmple64_f32(a, b) ::intrin::cmple64_f32(a, b)
#    define _cmpge64_f32(a, b) ::intrin::cmpge64_f32(a, b)
#    define _recipl64_f32(a) ::intrin::recipl64_f32(a)
#    define _reciph64_f32(a) ::intrin::reciph64_f32(a)
#    define _rsqrtl64_f32(a) ::intrin::rsqrtl64_f32(a)
#    define _rsqrth64_f32(a) ::intrin::rsqrth64_f32(a)
#    define _sqrtl64_f32(a) ::intrin::sqrtl64_f32(a)
#    define _sqrth64_f32(a) ::intrin::sqrth64_f32(a)

#    define _dup64_s32(a) ::intrin::dup64_s32(a)
#    define _dupzero64_s32() _cast64_s32_f32(_dupzero64_f32())
#    define _set64_s32(a, b) ::intrin::set64_s32(a, b)
#    define _shufft64_s32(a, b, n1, n0) _cast64_s32_f32(_shufft64_f32(_cast64_f32_s32(a), _cast64_f32_s32(b), n1, n0))
#    define _shuffo64_s32(a, n1, n0) _cast64_s32_f32(_shuffo64_f32(_cast64_f32_s32(a), n1, n0))
#    define _add64_s32(a, b) ::intrin::add64_s32(a, b)
#    define _sub64_s32(a, b) ::intrin::sub64_s32(a, b)
#    define _mul64_s32(a, b) ::intrin::mul64_s32(a, b)
#    define _madd64_s32(a, b, c) ::intrin::madd64_s32(a, b, c)
#    define _neg64_s32(a) ::intrin::neg64_s32(a)
#    define _abs64_s32(a) ::intrin::abs64_s32(a)
#    define _max64_s32(a, b) ::intrin::max64_s32(a, b)
#    define _min64_s32(a, b) ::intrin::min64_s32(a, b)
#    define _clamp64_s32(a, min, max) _min64_s32(_max64_s32(a, min), max)
#    define _cmpeq64_s32(a, b) ::intrin::cmpeq64_s32(a, b)
#    define _cmplt64_s32(a, b) ::intrin::cmplt64_s32(a, b)
#    define _cmpgt64_s32(a, b) ::intrin::cmpgt64_s32(a, b)
#    define _cmple64_s32(a, b) ::intrin::cmple64_s32(a, b)
#    define _cmpge64_s32(a, b) ::intrin::cmpge64_s32(a, b)

#    define _cast64to32_f32(a) ::intrin::cast64to32_f32(a)
#    define _cast64_s32_f32(a) ::intrin::cast64_s32_f32(a)
#    define _cast64_f32_s32(a) ::intrin::cast64_f32_s32(a)
#    define _cast128to64_f32(a) ::intrin::cast128to64_f32(a)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON64)

#    define _round64_f32(a) ::intrin::round64_f32(a)
#    define _floor64_f32(a) ::intrin::floor64_f32(a)
#    define _ceil64_f32(a) ::intrin::ceil64_f32(a)

#    define _padd64_f32(a, b) ::intrin::padd64_f32(a, b)
#    define _radd128_f32(a) ::intrin::radd128_f32(a)
#    define _rmax128_f32(a) ::intrin::rmax128_f32(a)
#    define _rmin128_f32(a) ::intrin::rmin128_f32(a)

#    define _padd64_s32(a, b) ::intrin::padd64_s32(a, b)
#    define _radd128_s32(a) ::intrin::radd128_s32(a)
#    define _rmax128_s32(a) ::intrin::rmax128_s32(a)
#    define _rmin128_s32(a) ::intrin::rmin128_s32(a)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_SSE3)

#    define _psub128_f32(a, b) ::intrin::psub128_f32(a, b)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_SSSE3)

#    define _psub128_s32(a, b) ::intrin::psub128_s32(a, b)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_SSE4_1)

#    define _dot128_f32(a, b, dot, str) ::intrin::dot128_f32<dot, str>(a, b)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_AVX)

#    define _load256_f32(p) ::intrin::load256_f32(p)
#    define _store256_f32(p, a) ::intrin::store256_f32(p, a)
#    define _shuffo256_f32(a, n7, n6, n5, n4, n3, n2, n1, n0) \
        ::intrin::shuffle256_f32<n7, n6, n5, n4, n3, n2, n1, n0>(a)
#    define _mul256_f32(a, b) ::intrin::mul256_f32(a, b)
#    define _madd256_f32(a, b, c) ::intrin::madd256_f32(a, b, c)

#    define _shuffo256_s32(a, n7, n6, n5, n4, n3, n2, n1, n0) \
        _cast256_s32_f32(_shuffo256_f32(_cast256_f32_s32(a), n7, n6, n5, n4, n3, n2, n1, n0))

#    define _cast256_s32_f32(a) ::intrin::cast256_s32_f32(a)
#    define _cast256_f32_s32(a) ::intrin::cast256_f32_s32(a)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_AVX2)

#    define _mul256_s32(a, b) ::intrin::mul256_s32(a, b)
#    define _madd256_s32(a, b, c) ::intrin::madd256_s32(a, b, c)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

#    define _load128_f32(p) ::intrin::load128_f32(p)
#    define _store128_f32(p, a) ::intrin::store128_f32(p, a)
#    define _dup128_f32(a) ::intrin::dup128_f32(a)
#    define _dupzero128_f32() ::intrin::dupzero128_f32()
#    define _set128_f32(a, b, c, d) ::intrin::set128_f32(a, b, c, d)
#    define _shufft128_f32(a, b, n3, n2, n1, n0) ::intrin::shuffle128_f32<n3, n2, n1, n0>(a, b)
#    define _shuffo128_f32(a, n3, n2, n1, n0) ::intrin::shuffle128_f32<n3, n2, n1, n0>(a)
#    define _and128_f32(a, b) ::intrin::and128_f32(a, b)
#    define _or128_f32(a, b) ::intrin::or128_f32(a, b)
#    define _xor128_f32(a, b) ::intrin::xor128_f32(a, b)
#    define _add128_f32(a, b) ::intrin::add128_f32(a, b)
#    define _sub128_f32(a, b) ::intrin::sub128_f32(a, b)
#    define _mul128_f32(a, b) ::intrin::mul128_f32(a, b)
#    define _div128_f32(a, b) ::intrin::div128_f32(a, b)
#    define _madd128_f32(a, b, c) ::intrin::madd128_f32(a, b, c)
#    define _neg128_f32(a) ::intrin::neg128_f32(a)
#    define _abs128_f32(a) ::intrin::abs128_f32(a)
#    define _max128_f32(a, b) ::intrin::max128_f32(a, b)
#    define _min128_f32(a, b) ::intrin::min128_f32(a, b)
#    define _clamp128_f32(a, min, max) _min128_f32(_max128_f32(a, min), max)
#    define _cmpeq128_f32(a, b) ::intrin::cmpeq128_f32(a, b)
#    define _cmplt128_f32(a, b) ::intrin::cmplt128_f32(a, b)
#    define _cmpgt128_f32(a, b) ::intrin::cmpgt128_f32(a, b)
#    define _cmple128_f32(a, b) ::intrin::cmple128_f32(a, b)
#    define _cmpge128_f32(a, b) ::intrin::cmpge128_f32(a, b)
#    define _recipl128_f32(a) ::intrin::recipl128_f32(a)
#    define _reciph128_f32(a) ::intrin::reciph128_f32(a)
#    define _rsqrtl128_f32(a) ::intrin::rsqrtl128_f32(a)
#    define _rsqrth128_f32(a) ::intrin::rsqrth128_f32(a)
#    define _sqrtl128_f32(a) ::intrin::sqrtl128_f32(a)
#    define _sqrth128_f32(a) ::intrin::sqrth128_f32(a)

#    define _cast128to32_f32(a) ::intrin::cast128to32_f32(a)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2 | KTM_SIMD_WASM)

#    define _dup128_s32(a) ::intrin::dup128_s32(a)
#    define _dupzero128_s32() _cast128_s32_f32(_dupzero128_f32())
#    define _set128_s32(a, b, c, d) ::intrin::set128_s32(a, b, c, d)
#    define _shufft128_s32(a, b, n3, n2, n1, n0) \
        _cast128_s32_f32(_shufft128_f32(_cast128_f32_s32(a), _cast128_f32_s32(b), n3, n2, n1, n0))
#    define _shuffo128_s32(a, n3, n2, n1, n0) _cast128_s32_f32(_shuffo128_f32(_cast128_f32_s32(a), n3, n2, n1, n0))
#    define _add128_s32(a, b) ::intrin::add128_s32(a, b)
#    define _sub128_s32(a, b) ::intrin::sub128_s32(a, b)
#    define _neg128_s32(a) ::intrin::neg128_s32(a)
#    define _abs128_s32(a) ::intrin::abs128_s32(a)
#    define _cmpeq128_s32(a, b) ::intrin::cmpeq128_s32(a, b)
#    define _cmplt128_s32(a, b) ::intrin::cmplt128_s32(a, b)
#    define _cmpgt128_s32(a, b) ::intrin::cmpgt128_s32(a, b)
#    define _cmple128_s32(a, b) ::intrin::cmple128_s32(a, b)
#    define _cmpge128_s32(a, b) ::intrin::cmpge128_s32(a, b)

#    define _cast128_s32_f32(a) ::intrin::cast128_s32_f32(a)
#    define _cast128_f32_s32(a) ::intrin::cast128_f32_s32(a)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON64 | KTM_SIMD_SSE3)

#    define _padd128_f32(a, b) ::intrin::padd128_f32(a, b)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON64 | KTM_SIMD_SSSE3)

#    define _padd128_s32(a, b) ::intrin::padd128_s32(a, b)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#    define _mul128_s32(a, b) ::intrin::mul128_s32(a, b)
#    define _madd128_s32(a, b, c) ::intrin::madd128_s32(a, b, c)
#    define _max128_s32(a, b) ::intrin::max128_s32(a, b)
#    define _min128_s32(a, b) ::intrin::min128_s32(a, b)
#    define _clamp128_s32(a, min, max) _min128_s32(_max128_s32(a, min), max)

#endif

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON64 | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#    define _round128_f32(a) ::intrin::round128_f32(a)
#    define _floor128_f32(a) ::intrin::floor128_f32(a)
#    define _ceil128_f32(a) ::intrin::ceil128_f32(a)

#endif

#endif