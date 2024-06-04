//  MIT License
//
//  Copyright (c) 2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMP_CALC_INL_
#define _KTM_COMP_CALC_INL_

#include "comp_calc_fwd.h"
#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/comp_fwd.h"
#include "../../function/geometric.h"

template<typename T, typename Void>
struct ktm::detail::comp_calc_implement::mul
{
    using C = comp<T>;
    static KTM_INLINE C call(const C& x, const C& y) noexcept
    {
        return C(x[0] * y[1] + x[1] * y[0], x[1] * y[1] - x[0] * y[0]);
    }
};

template<typename T, typename Void>
struct ktm::detail::comp_calc_implement::mul_to_self
{
    using C = comp<T>;
    static KTM_INLINE void call(C& x, const C& y) noexcept
    {
        C tmp = x;
        x[0] = tmp[0] * y[1] + tmp[1] * y[0];
        x[1] = tmp[1] * y[1] - tmp[0] * y[0];
    }
};

template<typename T, typename Void>
struct ktm::detail::comp_calc_implement::act
{
    using C = comp<T>;
    static KTM_INLINE vec<2, T> call(const C& c, const vec<2,T>& v) noexcept
    {   
        return vec<2, T>(c[1] * v[0] - c[0] * v[1] , ktm::dot(*c, v));
    }
};

#endif