//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_TRANSFORM_2D_H_
#define _KTM_MATRIX_TRANSFORM_2D_H_

#include "../../setup.h"
#include "../../type/vec.h"
#include "../../type/mat.h"
#include "../common.h"
#include "../geometric.h"

namespace ktm
{

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<3, 3, T>> rotate2d(T angle) noexcept
{
    T cos_theta = cos(angle);
    T sin_theta = sin(angle);
    return mat<3, 3, T> { { cos_theta, sin_theta, zero<T> },
                          { -sin_theta, cos_theta, zero<T> },
                          { zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<3, 3, T>> rotate2d_point(T angle,
                                                                                      const vec<2, T>& point) noexcept
{
    T cos_theta = cos(angle);
    T sin_theta = sin(angle);
    T one_minus_cos_theta = one<T> - cos_theta;
    return mat<3, 3, T> { { cos_theta, sin_theta, zero<T> },
                          { -sin_theta, cos_theta, zero<T> },
                          { point[0] * one_minus_cos_theta + point[1] * sin_theta,
                            point[1] * one_minus_cos_theta - point[0] * sin_theta, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<3, 3, T>> rotate2d_from_to(const vec<2, T>& from,
                                                                                        const vec<2, T>& to) noexcept
{
    T cos_theta = dot(from, to);
    T sin_theta = from[0] * to[1] - from[1] * to[0];
    return mat<3, 3, T> { { cos_theta, sin_theta, zero<T> },
                          { -sin_theta, cos_theta, zero<T> },
                          { zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<3, 3, T>> translate2d(const vec<2, T>& v) noexcept
{
    return mat<3, 3, T> { { one<T>, zero<T>, zero<T> }, { zero<T>, one<T>, zero<T> }, { v[0], v[1], one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<3, 3, T>> scale2d(const vec<2, T>& v) noexcept
{
    return mat<3, 3, T> { { v[0], zero<T>, zero<T> }, { zero<T>, v[1], zero<T> }, { zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<3, 3, T>> shear2d_x(T angle_y) noexcept
{
    return mat<3, 3, T> { { one<T>, zero<T>, zero<T> },
                          { tan(angle_y), one<T>, zero<T> },
                          { zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<3, 3, T>> shear2d_y(T angle_x) noexcept
{
    return mat<3, 3, T> { { one<T>, tan(angle_x), zero<T> },
                          { zero<T>, one<T>, zero<T> },
                          { zero<T>, zero<T>, one<T> } };
}

} // namespace ktm

#endif