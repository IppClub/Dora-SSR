//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_VEC_CALC_H_
#define _KTM_I_VEC_CALC_H_

#include "../../setup.h"
#include "../../detail/vector/vec_calc_fwd.h"

namespace ktm
{

template <class Father, class Child>
struct ivec_calc;

template <class Father, size_t N, typename T>
struct ivec_calc<Father, vec<N, T>> : Father
{
};

template <class Father, typename T>
struct ivec_calc<Father, vec<3, T>> : Father
{
    using Father::child_ptr;
    using Father::Father;

private:
    template <class F, class C>
    friend struct iarray_add;

    KTM_INLINE vec<3, T> add_impl(const vec<3, T>& y) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::add<T>(ret, *child_ptr(), y);
        return ret;
    }

    KTM_INLINE vec<3, T>& add_to_self_impl(const vec<3, T>& y) noexcept
    {
        detail::vec_calc_implement::add<T>(*child_ptr(), *child_ptr(), y);
        return *child_ptr();
    }

    KTM_INLINE vec<3, T> sub_impl(const vec<3, T>& y) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::sub<T>(ret, *child_ptr(), y);
        return ret;
    }

    KTM_INLINE vec<3, T>& sub_to_self_impl(const vec<3, T>& y) noexcept
    {
        detail::vec_calc_implement::sub<T>(*child_ptr(), *child_ptr(), y);
        return *child_ptr();
    }

    KTM_INLINE vec<3, T> neg_impl() const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::neg<T>(ret, *child_ptr());
        return ret;
    }

    template <class F, class C>
    friend struct iarray_mul;

    KTM_INLINE vec<3, T> mul_impl(const vec<3, T>& y) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::mul<T>(ret, *child_ptr(), y);
        return ret;
    }

    KTM_INLINE vec<3, T>& mul_to_self_impl(const vec<3, T>& y) noexcept
    {
        detail::vec_calc_implement::mul<T>(*child_ptr(), *child_ptr(), y);
        return *child_ptr();
    }

    KTM_INLINE vec<3, T> div_impl(const vec<3, T>& y) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::div<T>(ret, *child_ptr(), y);
        return ret;
    }

    KTM_INLINE vec<3, T>& div_to_self_impl(const vec<3, T>& y) noexcept
    {
        detail::vec_calc_implement::div<T>(*child_ptr(), *child_ptr(), y);
        return *child_ptr();
    }

    template <class F, class C>
    friend struct iarray_madd;

    KTM_INLINE vec<3, T> madd_impl(const vec<3, T>& y, const vec<3, T>& z) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::madd<T>(ret, *child_ptr(), y, z);
        return ret;
    }

    KTM_INLINE vec<3, T>& madd_to_self_impl(const vec<3, T>& y, const vec<3, T>& z) noexcept
    {
        detail::vec_calc_implement::madd<T>(*child_ptr(), *child_ptr(), y, z);
        return *child_ptr();
    }

    template <class F, class C>
    friend struct iarray_add_scalar;

    KTM_INLINE vec<3, T> add_scalar_impl(T scalar) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::add_scalar<T>(ret, *child_ptr(), scalar);
        return ret;
    }

    KTM_INLINE vec<3, T>& add_scalar_to_self_impl(T scalar) noexcept
    {
        detail::vec_calc_implement::add_scalar<T>(*child_ptr(), *child_ptr(), scalar);
        return *child_ptr();
    }

    KTM_INLINE vec<3, T> sub_scalar_impl(T scalar) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::sub_scalar<T>(ret, *child_ptr(), scalar);
        return ret;
    }

    KTM_INLINE vec<3, T>& sub_scalar_to_self_impl(T scalar) noexcept
    {
        detail::vec_calc_implement::sub_scalar<T>(*child_ptr(), *child_ptr(), scalar);
        return *child_ptr();
    }

    template <class F, class C>
    friend struct iarray_mul_scalar;

    KTM_INLINE vec<3, T> mul_scalar_impl(T scalar) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::mul_scalar<T>(ret, *child_ptr(), scalar);
        return ret;
    }

    KTM_INLINE vec<3, T>& mul_scalar_to_self_impl(T scalar) noexcept
    {
        detail::vec_calc_implement::mul_scalar<T>(*child_ptr(), *child_ptr(), scalar);
        return *child_ptr();
    }

    KTM_INLINE vec<3, T> div_scalar_impl(T scalar) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::div_scalar<T>(ret, *child_ptr(), scalar);
        return ret;
    }

    KTM_INLINE vec<3, T>& div_scalar_to_self_impl(T scalar) noexcept
    {
        detail::vec_calc_implement::div_scalar<T>(*child_ptr(), *child_ptr(), scalar);
        return *child_ptr();
    }

    template <class F, class C>
    friend struct iarray_madd_scalar;

    KTM_INLINE vec<3, T> madd_scalar_impl(const vec<3, T>& y, T scalar) const noexcept
    {
        vec<3, T> ret;
        detail::vec_calc_implement::madd_scalar<T>(ret, *child_ptr(), y, scalar);
        return ret;
    }

    KTM_INLINE vec<3, T>& madd_scalar_to_self_impl(const vec<3, T>& y, T scalar) noexcept
    {
        detail::vec_calc_implement::madd_scalar<T>(*child_ptr(), *child_ptr(), y, scalar);
        return *child_ptr();
    }
};

} // namespace ktm
#endif
