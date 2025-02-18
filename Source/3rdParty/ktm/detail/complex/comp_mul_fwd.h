//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMP_MUL_FWD_H_
#define _KTM_COMP_MUL_FWD_H_

#include "../../type/vec_fwd.h"
#include "../../type/comp_fwd.h"
#include "../../setup.h"

namespace ktm
{
namespace detail
{
namespace comp_mul_implement
{

template <typename T>
KTM_INLINE void mul(comp<T>& out, const comp<T>& x, const comp<T>& y) noexcept;

template <typename T>
KTM_INLINE void act(vec<2, T>& out, const comp<T>& c, const vec<2, T>& v) noexcept;

} // namespace comp_mul_implement
} // namespace detail
} // namespace ktm

#endif