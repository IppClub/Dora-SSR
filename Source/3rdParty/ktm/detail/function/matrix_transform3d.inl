//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_TRANSFORM_3D_FWD_INL_
#define _KTM_MATRIX_TRANSFORM_3D_FWD_INL_

#include "matrix_transform3d_fwd.h"
#include "../../type/basic.h"

template <typename T, typename StartV, typename Void>
KTM_NOINLINE std::enable_if_t<std::is_floating_point_v<T>>
ktm::detail::matrix_transform3d_implement::rotate3d_normal(ktm::mat<4, 4, T>& out, T sin_theta, T cos_theta,
                                                           const vec<3, T>& normal, StartV&& normal_start) noexcept
{
    T one_minus_cos_theta = one<T> - cos_theta;
    T xx_one_minus_cos = normal[0] * normal[0] * one_minus_cos_theta;
    T xy_one_minus_cos = normal[0] * normal[1] * one_minus_cos_theta;
    T xz_one_minus_cos = normal[0] * normal[2] * one_minus_cos_theta;
    T yy_one_minus_cos = normal[1] * normal[1] * one_minus_cos_theta;
    T yz_one_minus_cos = normal[1] * normal[2] * one_minus_cos_theta;
    T zz_one_minus_cos = normal[2] * normal[2] * one_minus_cos_theta;
    T x_sin = normal[0] * sin_theta, y_sin = normal[1] * sin_theta, z_sin = normal[2] * sin_theta;
    out[0] = { xx_one_minus_cos + cos_theta, xy_one_minus_cos + z_sin, xz_one_minus_cos - y_sin, zero<T> };
    out[1] = { xy_one_minus_cos - z_sin, yy_one_minus_cos + cos_theta, yz_one_minus_cos + x_sin, zero<T> };
    out[2] = { xz_one_minus_cos + y_sin, yz_one_minus_cos - x_sin, zz_one_minus_cos + cos_theta, zero<T> };
    if constexpr (std::is_same_v<StartV, ktm::vec<3, T>>)
    {
        T a = normal_start[0], b = normal_start[1], c = normal_start[2];
        out[3] = { a * (one_minus_cos_theta - xx_one_minus_cos) + b * (z_sin - xy_one_minus_cos) -
                       c * (y_sin + xz_one_minus_cos),
                   b * (one_minus_cos_theta - yy_one_minus_cos) + c * (x_sin - yz_one_minus_cos) -
                       a * (z_sin + xy_one_minus_cos),
                   c * (one_minus_cos_theta - zz_one_minus_cos) + a * (y_sin - xz_one_minus_cos) -
                       b * (x_sin + yz_one_minus_cos),
                   one<T> };
    }
    else
    {
        out[3] = { zero<T>, zero<T>, zero<T>, one<T> };
    }
}

#endif