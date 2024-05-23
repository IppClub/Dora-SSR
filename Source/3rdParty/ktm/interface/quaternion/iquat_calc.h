//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_QUAT_CALC_H_
#define _KTM_I_QUAT_CALC_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/quat_fwd.h"
#include "../../detail/vector/vec_calc_fwd.h"
#include "../../detail/quaternion/quat_calc_fwd.h"

namespace ktm
{
template<class Father, class Child>
struct iquat_calc;

template<class Father, typename T>
struct iquat_calc<Father, quat<T>> : Father
{
    using Father::Father;

    KTM_INLINE quat<T> operator+(const quat<T>& y) const noexcept
    {
        quat<T> ret;
        ret.vector = detail::vec_calc_implement::add<4, T>::call(reinterpret_cast<const vec<4, T>&>(*this), y.vector);
        return ret;
    }

    KTM_INLINE quat<T>& operator+=(const quat<T>& y) noexcept
    {
        detail::vec_calc_implement::add_to_self<4, T>::call(reinterpret_cast<vec<4, T>&>(*this), y.vector);
        return reinterpret_cast<quat<T>&>(*this);
    }

    KTM_INLINE quat<T> operator-(const quat<T>& y) const noexcept
    {
        quat<T> ret;
        ret.vector = detail::vec_calc_implement::minus<4, T>::call(reinterpret_cast<const vec<4, T>&>(*this), y.vector);
        return ret;
    }

    KTM_INLINE quat<T> operator-() const noexcept
    {
        return detail::vec_calc_implement::opposite<4, T>::call(reinterpret_cast<const vec<4, T>&>(*this));
    }

    KTM_INLINE quat<T>& operator-=(const quat<T>& y) noexcept
    {
        detail::vec_calc_implement::minus_to_self<4, T>::call(reinterpret_cast<vec<4, T>&>(*this), y.vector);
        return reinterpret_cast<quat<T>&>(*this);
    }

    KTM_INLINE quat<T> operator*(const quat<T>& y) const noexcept
    {
        return detail::quat_calc_implement::mul<T>::call(reinterpret_cast<const quat<T>&>(*this), y);
    }

    KTM_INLINE quat<T>& operator*=(const quat<T>& y) noexcept
    {
        quat<T>& this_ref = reinterpret_cast<quat<T>&>(*this);
        detail::quat_calc_implement::mul_to_self<T>::call(this_ref, y); 
        return this_ref;
    }

    KTM_INLINE vec<3, T> operator*(const vec<3, T>& v) const noexcept
    {
        return detail::quat_calc_implement::act<T>::call(reinterpret_cast<const quat<T>&>(*this), v); 
    }

    KTM_INLINE quat<T> operator*(T scalar) const noexcept
    {
        quat<T> ret;
        ret.vector = detail::vec_calc_implement::mul_scalar<4, T>::call(reinterpret_cast<const vec<4, T>&>(*this), scalar);
        return ret;
    }

    friend KTM_INLINE quat<T> operator*(T scalar, const quat<T>& x) noexcept 
    { 
        return x * scalar; 
    }

    KTM_INLINE quat<T>& operator*=(T scalar) noexcept
    {
        detail::vec_calc_implement::mul_scalar_to_self<4, T>::call(reinterpret_cast<vec<4, T>&>(*this), scalar);
        return reinterpret_cast<quat<T>&>(*this);
    }
};

}

#endif