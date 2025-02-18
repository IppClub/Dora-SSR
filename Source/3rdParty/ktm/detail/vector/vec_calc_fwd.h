//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_CALC_FWD_H_
#define _KTM_VEC_CALC_FWD_H_

#include "../../type/vec_fwd.h"
#include "../../setup.h"

namespace ktm
{
namespace detail
{
namespace vec_calc_implement
{

template <typename T>
KTM_INLINE void add(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y) noexcept;

template <typename T>
KTM_INLINE void sub(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y) noexcept;

template <typename T>
KTM_INLINE void neg(vec<3, T>& out, const vec<3, T>& x) noexcept;

template <typename T>
KTM_INLINE void mul(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y) noexcept;

template <typename T>
KTM_INLINE void div(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y) noexcept;

template <typename T>
KTM_INLINE void madd(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y, const vec<3, T>& z) noexcept;

template <typename T>
KTM_INLINE void add_scalar(vec<3, T>& out, const vec<3, T>& x, T scalar) noexcept;

template <typename T>
KTM_INLINE void sub_scalar(vec<3, T>& out, const vec<3, T>& x, T scalar) noexcept;

template <typename T>
KTM_INLINE void mul_scalar(vec<3, T>& out, const vec<3, T>& x, T scalar) noexcept;

template <typename T>
KTM_INLINE void div_scalar(vec<3, T>& out, const vec<3, T>& x, T scalar) noexcept;

template <typename T>
KTM_INLINE void madd_scalar(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y, T scalar) noexcept;

} // namespace vec_calc_implement
} // namespace detail
} // namespace ktm

#endif
