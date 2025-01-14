//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMP_MUL_INL_
#define _KTM_COMP_MUL_INL_

#include "comp_mul_fwd.h"
#include "../../function/geometric.h"

template <typename T>
KTM_INLINE void ktm::detail::comp_mul_implement::mul(comp<T>& out, const comp<T>& x, const comp<T>& y) noexcept
{
    out = comp<T>(x[0] * y[1] + x[1] * y[0], x[1] * y[1] - x[0] * y[0]);
}

template <typename T>
KTM_INLINE void ktm::detail::comp_mul_implement::act(vec<2, T>& out, const comp<T>& c, const vec<2, T>& v) noexcept
{
    out = vec<2, T>(c[1] * v[0] - c[0] * v[1], ktm::dot(*c, v));
}

#endif