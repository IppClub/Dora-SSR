//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_COMP_DATA_H_
#define _KTM_I_COMP_DATA_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/comp_fwd.h"
#include "../../type/mat_fwd.h"
#include "../../detail/vector/vec_data_fwd.h"
#include "../../function/common.h"

namespace ktm
{

template <class Father, class Child>
struct icomp_data;

template <class Father, typename T>
struct icomp_data<Father, comp<T>> : Father
{
    using Father::Father;

    union
    {
        struct
        {
            T i, r;
        };

        typename detail::vec_data_implement::vec_storage<2, T>::type st;
    };

    KTM_FUNC constexpr icomp_data() noexcept : i(zero<T>), r(zero<T>) {};
    icomp_data(const icomp_data&) = default;
    icomp_data(icomp_data&&) = default;
    icomp_data& operator=(const icomp_data&) = default;
    icomp_data& operator=(icomp_data&&) = default;

    KTM_FUNC constexpr icomp_data(T x, T y) noexcept : i(x), r(y) {}

    KTM_FUNC constexpr icomp_data(const vec<2, T> vec) noexcept : i(vec.x), r(vec.y) {}

    KTM_FUNC T real() const noexcept { return r; }

    KTM_FUNC T imag() const noexcept { return i; }

    KTM_FUNC T angle() const noexcept { return atan2(imag(), real()); }

    KTM_FUNC vec<2, T>& operator*() noexcept { return reinterpret_cast<vec<2, T>&>(st); }

    KTM_FUNC const vec<2, T>& operator*() const noexcept { return reinterpret_cast<const vec<2, T>&>(st); }

    KTM_INLINE mat<2, 2, T> matrix2x2() const noexcept { return mat<2, 2, T>(vec<2, T>(r, i), vec<2, T>(-i, r)); }

    KTM_INLINE mat<3, 3, T> matrix3x3() const noexcept
    {
        return mat<3, 3, T>(vec<3, T>(r, i, zero<T>), vec<3, T>(-i, r, zero<T>), vec<3, T>(zero<T>, zero<T>, one<T>));
    }
};

} // namespace ktm

#endif