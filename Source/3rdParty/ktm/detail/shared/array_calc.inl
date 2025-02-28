//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_ARRAY_CALC_INL_
#define _KTM_ARRAY_CALC_INL_

#include "array_calc_fwd.h"
#include "../loop_util.h"
#include "../../type/basic.h"

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::add
{
    using A = std::array<T, N>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        loop_op<N, A>::call(out, std::plus<T>(), x, y);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::sub
{
    using A = std::array<T, N>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        loop_op<N, A>::call(out, std::minus<T>(), x, y);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::neg
{
    using A = std::array<T, N>;

    static KTM_INLINE void call(A& out, const A& x) noexcept { loop_op<N, A>::call(out, std::negate<T>(), x); }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::mul
{
    using A = std::array<T, N>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        loop_op<N, A>::call(out, std::multiplies<T>(), x, y);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::div
{
    using A = std::array<T, N>;

    static KTM_INLINE void call(A& out, const A& x, const A& y) noexcept
    {
        loop_op<N, A>::call(out, std::divides<T>(), x, y);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::madd
{
    using A = std::array<T, N>;

    static KTM_INLINE void call(A& out, const A& x, const A& y, const A& z) noexcept
    {
        loop_op<N, A>::call(out, [](const T& x, const T& y, const T& z) -> T { return ktm_op_madd(x, y, z); }, x, y, z);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::add_scalar
{
    using A = std::array<T, N>;

    template <typename S>
    static KTM_INLINE std::enable_if_t<std::is_arithmetic_v<S>> call(A& out, const A& x, S scalar) noexcept
    {
        loop_op<N, A>::call(out, [&scalar](const T& x) -> T { return x + scalar; }, x);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::sub_scalar
{
    using A = std::array<T, N>;

    template <typename S>
    static KTM_INLINE std::enable_if_t<std::is_arithmetic_v<S>> call(A& out, const A& x, S scalar) noexcept
    {
        loop_op<N, A>::call(out, [&scalar](const T& x) -> T { return x - scalar; }, x);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::mul_scalar
{
    using A = std::array<T, N>;

    template <typename S>
    static KTM_INLINE std::enable_if_t<std::is_arithmetic_v<S>> call(A& out, const A& x, S scalar) noexcept
    {
        loop_op<N, A>::call(out, [&scalar](const T& x) -> T { return x * scalar; }, x);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::div_scalar
{
    using A = std::array<T, N>;

    template <typename S>
    static KTM_INLINE std::enable_if_t<std::is_arithmetic_v<S>> call(A& out, const A& x, S scalar) noexcept
    {
        if constexpr (std::is_floating_point_v<S>)
            ktm::detail::array_calc_implement::mul_scalar<T, N>::call(out, x, one<S> / scalar);
        else
            loop_op<N, A>::call(out, [&scalar](const T& x) -> T { return x / scalar; }, x);
    }
};

template <typename T, size_t N, typename Void>
struct ktm::detail::array_calc_implement::madd_scalar
{
    using A = std::array<T, N>;

    template <typename S>
    static KTM_INLINE std::enable_if_t<std::is_arithmetic_v<S>> call(A& out, const A& x, const A& y, S scalar) noexcept
    {
        loop_op<N, A>::call(out, [&scalar](const T& x, const T& y) -> T { return ktm_op_madd(x, y, scalar); }, x, y);
    }
};

#endif
