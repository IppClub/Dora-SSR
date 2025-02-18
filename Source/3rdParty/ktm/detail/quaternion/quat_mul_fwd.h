//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_QUAT_MUL_FWD_H_
#define _KTM_QUAT_MUL_FWD_H_

#include "../../type/vec_fwd.h"
#include "../../type/quat_fwd.h"
#include "../../setup.h"

namespace ktm
{
namespace detail
{
namespace quat_mul_implement
{

template <typename T>
KTM_INLINE void mul(quat<T>& out, const quat<T>& x, const quat<T>& y) noexcept;

template <typename T>
KTM_INLINE void act(vec<3, T>& out, const quat<T>& q, const vec<3, T>& v) noexcept;

} // namespace quat_mul_implement
} // namespace detail
} // namespace ktm

#endif