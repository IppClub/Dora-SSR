//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_CALC_SIMD_INL_
#define _KTM_VEC_CALC_SIMD_INL_

#include "vec_calc_fwd.h"
#include "../../simd/skv.h"

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE | KTM_SIMD_WASM)

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::add<float>(vec<3, float>& out, const vec<3, float>& x,
                                                            const vec<3, float>& y) noexcept
{
    out.st = _add128_f32(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::sub<float>(vec<3, float>& out, const vec<3, float>& x,
                                                            const vec<3, float>& y) noexcept
{
    out.st = _sub128_f32(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::neg<float>(vec<3, float>& out, const vec<3, float>& x) noexcept
{
    out.st = _neg128_f32(x.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::mul<float>(vec<3, float>& out, const vec<3, float>& x,
                                                            const vec<3, float>& y) noexcept
{
    out.st = _mul128_f32(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::div<float>(vec<3, float>& out, const vec<3, float>& x,
                                                            const vec<3, float>& y) noexcept
{
    out.st = _div128_f32(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::madd<float>(vec<3, float>& out, const vec<3, float>& x,
                                                             const vec<3, float>& y, const vec<3, float>& z) noexcept
{
    out.st = _madd128_f32(x.st, y.st, z.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::add_scalar<float>(vec<3, float>& out, const vec<3, float>& x,
                                                                   float scalar) noexcept
{
    out.st = _add128_f32(x.st, _dup128_f32(scalar));
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::sub_scalar<float>(vec<3, float>& out, const vec<3, float>& x,
                                                                   float scalar) noexcept
{
    out.st = _sub128_f32(x.st, _dup128_f32(scalar));
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::mul_scalar<float>(vec<3, float>& out, const vec<3, float>& x,
                                                                   float scalar) noexcept
{
    out.st = _mul128_f32(x.st, _dup128_f32(scalar));
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::div_scalar<float>(vec<3, float>& out, const vec<3, float>& x,
                                                                   float scalar) noexcept
{
    out.st = _div128_f32(x.st, _dup128_f32(scalar));
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::madd_scalar<float>(vec<3, float>& out, const vec<3, float>& x,
                                                                    const vec<3, float>& y, float scalar) noexcept
{
    out.st = _madd128_f32(x.st, y.st, _dup128_f32(scalar));
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2)

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::add<int>(vec<3, int>& out, const vec<3, int>& x,
                                                          const vec<3, int>& y) noexcept
{
    out.st = _add128_s32(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::sub<int>(vec<3, int>& out, const vec<3, int>& x,
                                                          const vec<3, int>& y) noexcept
{
    out.st = _sub128_s32(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::neg<int>(vec<3, int>& out, const vec<3, int>& x) noexcept
{
    out.st = _neg128_s32(x.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::add_scalar<int>(vec<3, int>& out, const vec<3, int>& x,
                                                                 int scalar) noexcept
{
    out.st = _add128_s32(x.st, _dup128_s32(scalar));
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::sub_scalar<int>(vec<3, int>& out, const vec<3, int>& x,
                                                                 int scalar) noexcept
{
    out.st = _sub128_s32(x.st, _dup128_s32(scalar));
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE2)

#if KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1)

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::mul<int>(vec<3, int>& out, const vec<3, int>& x,
                                                          const vec<3, int>& y) noexcept
{
    out.st = _mul128_s32(x.st, y.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::madd<int>(vec<3, int>& out, const vec<3, int>& x, const vec<3, int>& y,
                                                           const vec<3, int>& z) noexcept
{
    out.st = _madd128_s32(x.st, y.st, z.st);
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::mul_scalar<int>(vec<3, int>& out, const vec<3, int>& x,
                                                                 int scalar) noexcept
{
    out.st = _mul128_s32(x.st, _dup128_s32(scalar));
}

template <>
KTM_INLINE void ktm::detail::vec_calc_implement::madd_scalar<int>(vec<3, int>& out, const vec<3, int>& x,
                                                                  const vec<3, int>& y, int scalar) noexcept
{
    out.st = _madd128_s32(x.st, y.st, _dup128_s32(scalar));
}

#endif // KTM_SIMD_ENABLE(KTM_SIMD_NEON | KTM_SIMD_SSE4_1 | KTM_SIMD_WASM)

#endif
