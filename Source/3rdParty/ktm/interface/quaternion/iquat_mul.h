//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_QUAT_MUL_H_
#define _KTM_I_QUAT_MUL_H_

#include "../../setup.h"
#include "../../detail/quaternion/quat_mul_fwd.h"

namespace ktm
{

template <class Father, class Child>
struct iquat_mul;

template <class Father, typename T>
struct iquat_mul<Father, quat<T>> : Father
{
    using Father::Father;

    friend KTM_INLINE quat<T> operator*(const quat<T>& x, const quat<T>& y) noexcept
    {
        quat<T> ret;
        detail::quat_mul_implement::mul<T>(ret, x, y);
        return ret;
    }

    friend KTM_INLINE quat<T>& operator*=(quat<T>& x, const quat<T>& y) noexcept
    {
        detail::quat_mul_implement::mul<T>(x, x, y);
        return x;
    }

    friend KTM_INLINE vec<3, T> operator*(const quat<T>& q, const vec<3, T>& v) noexcept
    {
        vec<3, T> ret;
        detail::quat_mul_implement::act<T>(ret, q, v);
        return ret;
    }
};

} // namespace ktm

#endif