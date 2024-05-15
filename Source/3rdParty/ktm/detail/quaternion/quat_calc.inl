//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_QUAT_CALC_INL_
#define _KTM_QUAT_CALC_INL_

#include "quat_calc_fwd.h"
#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/quat_fwd.h"
#include "../../function/geometric.h"

template<typename T, typename Void>
struct ktm::detail::quat_calc_implement::mul
{
    using Q = quat<T>;
    static KTM_INLINE Q call(const Q& x, const Q& y) noexcept
    {
        Q ret;
        ret[0] = x[3] * y[0] + y[3] * x[0] + x[1] * y[2] - x[2] * y[1];
        ret[1] = x[3] * y[1] + y[3] * x[1] + x[2] * y[0] - x[0] * y[2];
        ret[2] = x[3] * y[2] + y[3] * x[2] + x[0] * y[1] - x[1] * y[0];
        ret[3] = x[3] * y[3] - x[0] * y[0] - x[1] * y[1] - x[2] * y[2];
        return ret;
    }
};

template<typename T, typename Void>
struct ktm::detail::quat_calc_implement::mul_to_self
{
    using Q = quat<T>;
    static KTM_INLINE void call(Q& x, const Q& y) noexcept
    {
        Q tmp = x;
        x[0] = tmp[3] * y[0] + y[3] * tmp[0] + tmp[1] * y[2] - tmp[2] * y[1];
        x[1] = tmp[3] * y[1] + y[3] * tmp[1] + tmp[2] * y[0] - tmp[0] * y[2];
        x[2] = tmp[3] * y[2] + y[3] * tmp[2] + tmp[0] * y[1] - tmp[1] * y[0];
        x[3] = tmp[3] * y[3] - tmp[0] * y[0] - tmp[1] * y[1] - tmp[2] * y[2];
    }
};

template<typename T, typename Void>
struct ktm::detail::quat_calc_implement::act
{
    using Q = quat<T>;
    static KTM_INLINE vec<3, T> call(const Q& q, const vec<3,T>& v) noexcept
    {   
        vec<3, T> t = static_cast<T>(2) * ktm::cross(q.imag(), v);
        return v + (q.real() * t) + ktm::cross(q.imag(), t);
    }
};

#endif