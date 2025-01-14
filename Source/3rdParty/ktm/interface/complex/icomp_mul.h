//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_COMP_MUL_H_
#define _KTM_I_COMP_MUL_H_

#include "../../setup.h"
#include "../../detail/complex/comp_mul_fwd.h"

namespace ktm
{

template <class Father, class Child>
struct icomp_mul;

template <class Father, typename T>
struct icomp_mul<Father, comp<T>> : Father
{
    using Father::Father;

    friend KTM_INLINE comp<T> operator*(const comp<T>& x, const comp<T>& y) noexcept
    {
        comp<T> ret;
        detail::comp_mul_implement::mul<T>(ret, x, y);
        return ret;
    }

    friend KTM_INLINE comp<T>& operator*=(comp<T>& x, const comp<T>& y) noexcept
    {
        detail::comp_mul_implement::mul<T>(x, x, y);
        return x;
    }

    friend KTM_INLINE vec<2, T> operator*(const comp<T>& q, const vec<2, T>& v) noexcept
    {
        vec<2, T> ret;
        detail::comp_mul_implement::act<T>(ret, q, v);
        return ret;
    }
};

} // namespace ktm

#endif