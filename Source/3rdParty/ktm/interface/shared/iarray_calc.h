//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_ARRAY_CALC_H_
#define _KTM_I_ARRAY_CALC_H_

#include <tuple>
#include "../../setup.h"
#include "../../traits/type_traits_math.h"
#include "../../traits/type_single_extends.h"
#include "../../detail/shared/array_calc_fwd.h"

namespace ktm
{

#define KTM_ARRAY_CALC_CALL(calc_name, ...)                         \
    using ArrayT = std::decay_t<decltype(child_ptr()->to_array())>; \
    detail::array_calc_implement::calc_name<typename ArrayT::value_type, std::tuple_size_v<ArrayT>>::call(__VA_ARGS__);

template <class Father, class Child>
struct iarray_add : Father
{
    using Father::child_ptr;
    using Father::Father;

    friend KTM_FUNC Child operator+(const Child& x, const Child& y) noexcept { return x.add(y); }

    friend KTM_FUNC Child& operator+=(Child& x, const Child& y) noexcept { return x.add_to_self(y); }

    friend KTM_FUNC Child operator-(const Child& x, const Child& y) noexcept { return x.sub(y); }

    friend KTM_FUNC Child& operator-=(Child& x, const Child& y) noexcept { return x.sub_to_self(y); }

    friend KTM_FUNC Child operator-(const Child& x) noexcept { return x.neg(); }

private:
    KTM_CRTP_INTERFACE_REGISTER(add, add_impl)

    KTM_FUNC Child add(const Child& y) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, add_impl))
            return child_ptr()->add_impl(y);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(add, ret.to_array(), child_ptr()->to_array(), y.to_array())
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(add_to_self, add_to_self_impl)

    KTM_FUNC Child& add_to_self(const Child& y) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, add_to_self_impl))
            return child_ptr()->add_to_self_impl(y);
        else
        {
            KTM_ARRAY_CALC_CALL(add, child_ptr()->to_array(), child_ptr()->to_array(), y.to_array())
            return *child_ptr();
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(sub, sub_impl)

    KTM_FUNC Child sub(const Child& y) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, sub_impl))
            return child_ptr()->sub_impl(y);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(sub, ret.to_array(), child_ptr()->to_array(), y.to_array())
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(sub_to_self, sub_to_self_impl)

    KTM_FUNC Child& sub_to_self(const Child& y) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, sub_to_self_impl))
            return child_ptr()->sub_to_self_impl(y);
        else
        {
            KTM_ARRAY_CALC_CALL(sub, child_ptr()->to_array(), child_ptr()->to_array(), y.to_array())
            return *child_ptr();
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(neg, neg_impl)

    KTM_FUNC Child neg() const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, neg_impl))
            return child_ptr()->neg_impl();
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(neg, ret.to_array(), child_ptr()->to_array())
            return ret;
        }
    }
};

template <class Father, class Child>
struct iarray_mul : Father
{
    using Father::child_ptr;
    using Father::Father;

    friend KTM_FUNC Child operator*(const Child& x, const Child& y) noexcept { return x.mul(y); }

    friend KTM_FUNC Child& operator*=(Child& x, const Child& y) noexcept { return x.mul_to_self(y); }

    friend KTM_FUNC Child operator/(const Child& x, const Child& y) noexcept { return x.div(y); }

    friend KTM_FUNC Child& operator/=(Child& x, const Child& y) noexcept { return x.div_to_self(y); }

private:
    KTM_CRTP_INTERFACE_REGISTER(mul, mul_impl)

    KTM_FUNC Child mul(const Child& y) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, mul_impl))
            return child_ptr()->mul_impl(y);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(mul, ret.to_array(), child_ptr()->to_array(), y.to_array())
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(mul_to_self, mul_to_self_impl)

    KTM_FUNC Child& mul_to_self(const Child& y) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, mul_to_self_impl))
            return child_ptr()->mul_to_self_impl(y);
        else
        {
            KTM_ARRAY_CALC_CALL(mul, child_ptr()->to_array(), child_ptr()->to_array(), y.to_array())
            return *child_ptr();
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(div, div_impl)

    KTM_FUNC Child div(const Child& y) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, div_impl))
            return child_ptr()->div_impl(y);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(div, ret.to_array(), child_ptr()->to_array(), y.to_array())
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(div_to_self, div_to_self_impl)

    KTM_FUNC Child& div_to_self(const Child& y) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, div_to_self_impl))
            return child_ptr()->div_to_self_impl(y);
        else
        {
            KTM_ARRAY_CALC_CALL(div, child_ptr()->to_array(), child_ptr()->to_array(), y.to_array())
            return *child_ptr();
        }
    }
};

template <class Father, class Child>
struct iarray_add_scalar : Father
{
    using Father::child_ptr;
    using Father::Father;
    using ScalarT = typename math_traits<Child>::base_type;

    friend KTM_FUNC Child operator+(const Child& x, ScalarT scalar) noexcept { return x.add_scalar(scalar); }

    friend KTM_FUNC Child& operator+=(Child& x, ScalarT scalar) noexcept { return x.add_scalar_to_self(scalar); }

    friend KTM_FUNC Child operator-(const Child& x, ScalarT scalar) noexcept { return x.sub_scalar(scalar); }

    friend KTM_FUNC Child& operator-=(Child& x, ScalarT scalar) noexcept { return x.sub_scalar_to_self(scalar); }

    friend KTM_FUNC Child operator+(ScalarT scalar, const Child& x) noexcept { return x + scalar; }

private:
    KTM_CRTP_INTERFACE_REGISTER(add_scalar, add_scalar_impl)

    KTM_FUNC Child add_scalar(ScalarT scalar) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, add_scalar_impl))
            return child_ptr()->add_scalar_impl(scalar);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(add_scalar, ret.to_array(), child_ptr()->to_array(), scalar)
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(add_scalar_to_self, add_scalar_to_self_impl)

    KTM_FUNC Child& add_scalar_to_self(ScalarT scalar) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, add_scalar_to_self_impl))
            return child_ptr()->add_scalar_to_self_impl(scalar);
        else
        {
            KTM_ARRAY_CALC_CALL(add_scalar, child_ptr()->to_array(), child_ptr()->to_array(), scalar)
            return *child_ptr();
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(sub_scalar, sub_scalar_impl)

    KTM_FUNC Child sub_scalar(ScalarT scalar) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, sub_scalar_impl))
            return child_ptr()->sub_scalar_impl(scalar);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(sub_scalar, ret.to_array(), child_ptr()->to_array(), scalar)
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(sub_scalar_to_self, sub_scalar_to_self_impl)

    KTM_FUNC Child& sub_scalar_to_self(ScalarT scalar) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, sub_scalar_to_self_impl))
            return child_ptr()->sub_scalar_to_self_impl(scalar);
        else
        {
            KTM_ARRAY_CALC_CALL(sub_scalar, child_ptr()->to_array(), child_ptr()->to_array(), scalar)
            return *child_ptr();
        }
    }
};

template <class Father, class Child>
struct iarray_mul_scalar : Father
{
    using Father::child_ptr;
    using Father::Father;
    using ScalarT = typename math_traits<Child>::base_type;

    friend KTM_FUNC Child operator*(const Child& x, ScalarT scalar) noexcept { return x.mul_scalar(scalar); }

    friend KTM_FUNC Child& operator*=(Child& x, ScalarT scalar) noexcept { return x.mul_scalar_to_self(scalar); }

    friend KTM_FUNC Child operator/(const Child& x, ScalarT scalar) noexcept { return x.div_scalar(scalar); }

    friend KTM_FUNC Child& operator/=(Child& x, ScalarT scalar) noexcept { return x.div_scalar_to_self(scalar); }

    friend KTM_FUNC Child operator*(ScalarT scalar, const Child& x) noexcept { return x * scalar; }

private:
    KTM_CRTP_INTERFACE_REGISTER(mul_scalar, mul_scalar_impl)

    KTM_FUNC Child mul_scalar(ScalarT scalar) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, mul_scalar_impl))
            return child_ptr()->mul_scalar_impl(scalar);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(mul_scalar, ret.to_array(), child_ptr()->to_array(), scalar)
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(mul_scalar_to_self, mul_scalar_to_self_impl)

    KTM_FUNC Child& mul_scalar_to_self(ScalarT scalar) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, mul_scalar_to_self_impl))
            return child_ptr()->mul_scalar_to_self_impl(scalar);
        else
        {
            KTM_ARRAY_CALC_CALL(mul_scalar, child_ptr()->to_array(), child_ptr()->to_array(), scalar)
            return *child_ptr();
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(div_scalar, div_scalar_impl)

    KTM_FUNC Child div_scalar(ScalarT scalar) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, div_scalar_impl))
            return child_ptr()->div_scalar_impl(scalar);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(div_scalar, ret.to_array(), child_ptr()->to_array(), scalar)
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(div_scalar_to_self, div_scalar_to_self_impl)

    KTM_FUNC Child& div_scalar_to_self(ScalarT scalar) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, div_scalar_to_self_impl))
            return child_ptr()->div_scalar_to_self_impl(scalar);
        else
        {
            KTM_ARRAY_CALC_CALL(div_scalar, child_ptr()->to_array(), child_ptr()->to_array(), scalar)
            return *child_ptr();
        }
    }
};

template <class Father, class Child>
struct iarray_madd : Father
{
    using Father::child_ptr;
    using Father::Father;

    friend KTM_FUNC Child ktm_op_madd(const Child& x, const Child& y, const Child& z) noexcept { return x.madd(y, z); }

    friend KTM_FUNC Child ktm_op_smadd(Child& x, const Child& y, const Child& z) noexcept
    {
        return x.madd_to_self(y, z);
    }

private:
    KTM_CRTP_INTERFACE_REGISTER(madd, madd_impl)

    KTM_FUNC Child madd(const Child& y, const Child& z) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, madd_impl))
            return child_ptr()->madd_impl(y, z);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(madd, ret.to_array(), child_ptr()->to_array(), y.to_array(), z.to_array());
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(madd_to_self, madd_to_self_impl)

    KTM_FUNC Child& madd_to_self(const Child& y, const Child& z) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, madd_to_self_impl))
            return child_ptr()->madd_to_self_impl(y, z);
        else
        {
            KTM_ARRAY_CALC_CALL(madd, child_ptr()->to_array(), child_ptr()->to_array(), y.to_array(), z.to_array());
            return *child_ptr();
        }
    }
};

template <class Father, class Child>
struct iarray_madd_scalar : Father
{
    using Father::child_ptr;
    using Father::Father;
    using ScalarT = typename math_traits<Child>::base_type;

    friend KTM_FUNC Child ktm_op_madd(const Child& x, const Child& y, ScalarT scalar) noexcept
    {
        return x.madd_scalar(y, scalar);
    }

    friend KTM_FUNC Child ktm_op_madd(const Child& x, ScalarT scalar, const Child& z) noexcept
    {
        return x.madd_scalar(z, scalar);
    }

    friend KTM_FUNC Child ktm_op_smadd(Child& x, const Child& y, ScalarT scalar) noexcept
    {
        return x.madd_scalar_to_self(y, scalar);
    }

    friend KTM_FUNC Child ktm_op_smadd(Child& x, ScalarT scalar, const Child& z) noexcept
    {
        return x.madd_scalar_to_self(z, scalar);
    }

private:
    KTM_CRTP_INTERFACE_REGISTER(madd_scalar, madd_scalar_impl)

    KTM_FUNC Child madd_scalar(const Child& y, ScalarT scalar) const noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, madd_scalar_impl))
            return child_ptr()->madd_scalar_impl(y, scalar);
        else
        {
            Child ret;
            KTM_ARRAY_CALC_CALL(madd_scalar, ret.to_array(), child_ptr()->to_array(), y.to_array(), scalar);
            return ret;
        }
    }

    KTM_CRTP_INTERFACE_REGISTER(madd_scalar_to_self, madd_scalar_to_self_impl)

    KTM_FUNC Child& madd_scalar_to_self(const Child& y, ScalarT scalar) noexcept
    {
        if constexpr (KTM_CRTP_INTERFACE_IMPLEMENT(Child, madd_scalar_to_self_impl))
            return child_ptr()->madd_scalar_to_self_impl(y, scalar);
        else
        {
            KTM_ARRAY_CALC_CALL(madd_scalar, child_ptr()->to_array(), child_ptr()->to_array(), y.to_array(), scalar);
            return *child_ptr();
        }
    }
};

#undef KTM_ARRAY_CALC_CALL

template <class Father, class Child>
using iarray_add_calc = combine_interface<iarray_add, iarray_add_scalar>::type<Father, Child>;

template <class Father, class Child>
using iarray_mul_calc = combine_interface<iarray_mul, iarray_mul_scalar>::type<Father, Child>;

template <class Father, class Child>
using iarray_madd_calc = combine_interface<iarray_madd, iarray_madd_scalar>::type<Father, Child>;

template <class Father, class Child>
using iarray_calc = combine_interface<iarray_add_calc, iarray_mul_calc, iarray_madd_calc>::type<Father, Child>;

} // namespace ktm

#include "../../detail/shared/array_calc.inl"
#include "../../detail/shared/array_calc_simd.inl"

#endif