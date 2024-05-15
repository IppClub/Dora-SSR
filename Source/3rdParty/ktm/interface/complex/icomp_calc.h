//  MIT License
//
//  Copyright (c) 2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_COMP_CALC_H_
#define _KTM_I_COMP_CALC_H_

#include "../../setup.h"
#include "../../type/comp_fwd.h"
#include "../../type/vec_fwd.h"
#include "../../detail/vector/vec_calc_fwd.h"
#include "../../detail/complex/comp_calc_fwd.h"

namespace ktm
{
template<class Father, class Child>
struct icomp_calc;

template<class Father,typename T>
struct icomp_calc<Father, comp<T>> : Father
{
    using Father::Father;

    KTM_INLINE comp<T> operator+(const comp<T>& y) const noexcept
    {
        comp<T> ret;
        ret.vector = detail::vec_calc_implement::add<2, T>::call(reinterpret_cast<const vec<2, T>&>(*this), y.vector);
        return ret;
    }

    KTM_INLINE comp<T>& operator+=(const comp<T>& y) noexcept
    {
        detail::vec_calc_implement::add_to_self<2, T>::call(reinterpret_cast<vec<2, T>&>(*this), y.vector);
        return reinterpret_cast<comp<T>&>(*this);
    }

    KTM_INLINE comp<T> operator-(const comp<T>& y) const noexcept
    {
        comp<T> ret;
        ret.vector = detail::vec_calc_implement::minus<2, T>::call(reinterpret_cast<const vec<2, T>&>(*this), y.vector);
        return ret;
    }

    KTM_INLINE comp<T>& operator-=(const comp<T>& y) noexcept
    {
        detail::vec_calc_implement::minus_to_self<2, T>::call(reinterpret_cast<vec<2, T>&>(*this), y.vector);
        return reinterpret_cast<comp<T>&>(*this);
    }

    KTM_INLINE comp<T> operator*(const comp<T>& y) const noexcept
    {
        return detail::comp_calc_implement::mul<T>::call(reinterpret_cast<const comp<T>&>(*this), y);
    }

    KTM_INLINE comp<T>& operator*=(const comp<T>& y) noexcept
    {
        comp<T>& this_ref = reinterpret_cast<comp<T>&>(*this);
        detail::comp_calc_implement::mul_to_self<T>::call(this_ref, y); 
        return this_ref;
    }

    KTM_INLINE vec<2, T> operator*(const vec<2, T>& v) const noexcept
    {
        return detail::comp_calc_implement::act<T>::call(reinterpret_cast<const comp<T>&>(*this), v); 
    }

    KTM_INLINE comp<T> operator*(T scalar) const noexcept
    {
        comp<T> ret;
        ret.vector = detail::vec_calc_implement::mul_scalar<2, T>::call(reinterpret_cast<const vec<2, T>&>(*this), scalar);
        return ret;
    }

    friend KTM_INLINE comp<T> operator*(T scalar, const comp<T>& x) noexcept 
    { 
        return x * scalar; 
    }

    KTM_INLINE comp<T>& operator*=(T scalar) noexcept
    {
        detail::vec_calc_implement::mul_scalar_to_self<2, T>::call(reinterpret_cast<vec<2, T>&>(*this), scalar);
        return reinterpret_cast<comp<T>&>(*this);
    }
};
}

#endif