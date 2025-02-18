//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_QUAT_DATA_H_
#define _KTM_I_QUAT_DATA_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/quat_fwd.h"
#include "../../type/mat_fwd.h"
#include "../../detail/vector/vec_data_fwd.h"
#include "../../function/common.h"
#include "../../function/geometric.h"

namespace ktm
{

template <class Father, class Child>
struct iquat_data;

template <class Father, typename T>
struct iquat_data<Father, quat<T>> : Father
{
    using Father::Father;

    union
    {
        struct
        {
            T i, j, k, r;
        };

        typename detail::vec_data_implement::vec_storage<4, T>::type st;
    };

    KTM_FUNC constexpr iquat_data() noexcept : i(zero<T>), j(zero<T>), k(zero<T>), r(zero<T>) {};
    iquat_data(const iquat_data&) = default;
    iquat_data(iquat_data&&) = default;
    iquat_data& operator=(const iquat_data&) = default;
    iquat_data& operator=(iquat_data&&) = default;

    KTM_FUNC constexpr iquat_data(T x, T y, T z, T w) noexcept : i(x), j(y), k(z), r(w) {}

    KTM_FUNC constexpr iquat_data(const vec<4, T>& vec) noexcept : i(vec.x), j(vec.y), k(vec.z), r(vec.w) {}

    KTM_FUNC T real() const noexcept { return r; }

    KTM_FUNC vec<3, T> imag() const noexcept { return vec<3, T>(i, j, k); }

    KTM_FUNC T angle() const noexcept { return static_cast<T>(2) * atan2(length(imag()), real()); }

    KTM_FUNC vec<3, T> axis() const noexcept { return normalize(imag()); }

    KTM_FUNC vec<4, T>& operator*() noexcept { return reinterpret_cast<vec<4, T>&>(st); }

    KTM_FUNC const vec<4, T>& operator*() const noexcept { return reinterpret_cast<const vec<4, T>&>(st); }

    KTM_INLINE mat<3, 3, T> matrix3x3() const noexcept
    {
        mat<3, 3, T> ret;
        matrix(ret);
        return ret;
    }

    KTM_INLINE mat<4, 4, T> matrix4x4() const noexcept
    {
        mat<4, 4, T> ret {};
        matrix(reinterpret_cast<mat<3, 3, T>&>(ret));
        ret[3][3] = one<T>;
        return ret;
    }

private:
    KTM_NOINLINE void matrix(mat<3, 3, T>& m) const noexcept
    {
        T xx2 = i * i * static_cast<T>(2), yy2 = j * j * static_cast<T>(2), zz2 = k * k * static_cast<T>(2);
        T xy2 = i * j * static_cast<T>(2), xz2 = i * k * static_cast<T>(2), xw2 = i * r * static_cast<T>(2);
        T yz2 = j * k * static_cast<T>(2), yw2 = j * r * static_cast<T>(2), zw2 = k * r * static_cast<T>(2);
        m[0][0] = one<T> - (yy2 + zz2);
        m[0][1] = xy2 + zw2;
        m[0][2] = xz2 - yw2;
        m[1][0] = xy2 - zw2;
        m[1][1] = one<T> - (xx2 + zz2);
        m[1][2] = yz2 + xw2;
        m[2][0] = xz2 + yw2;
        m[2][1] = yz2 - xw2;
        m[2][2] = one<T> - (yy2 + xx2);
    }
};

} // namespace ktm

#endif