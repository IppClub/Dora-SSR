//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_QUAT_MUL_INL_
#define _KTM_QUAT_MUL_INL_

#include "quat_mul_fwd.h"
#include "../../function/geometric.h"

template <typename T>
KTM_INLINE void ktm::detail::quat_mul_implement::mul(quat<T>& out, const quat<T>& x, const quat<T>& y) noexcept
{
    out = quat<T>(
        x[3] * y[0] + y[3] * x[0] + x[1] * y[2] - x[2] * y[1], x[3] * y[1] + y[3] * x[1] + x[2] * y[0] - x[0] * y[2],
        x[3] * y[2] + y[3] * x[2] + x[0] * y[1] - x[1] * y[0], x[3] * y[3] - x[0] * y[0] - x[1] * y[1] - x[2] * y[2]);
}

template <typename T>
KTM_INLINE void ktm::detail::quat_mul_implement::act(vec<3, T>& out, const quat<T>& q, const vec<3, T>& v) noexcept
{
    vec<3, T> t = static_cast<T>(2) * ktm::cross(q.imag(), v);
    out = v + (q.real() * t) + ktm::cross(q.imag(), t);
}

#endif