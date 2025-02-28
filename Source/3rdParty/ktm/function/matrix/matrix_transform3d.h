//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_TRANSFORM_3D_H_
#define _KTM_MATRIX_TRANSFORM_3D_H_

#include "../../setup.h"
#include "../../type/vec.h"
#include "../../type/mat.h"
#include "../common.h"
#include "../geometric.h"
#include "../../detail/function/matrix_transform3d_fwd.h"

namespace ktm
{

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>>
look_to_lh(const vec<3, T>& eye_pos, const vec<3, T>& direction, const vec<3, T>& up) noexcept
{
    vec<3, T> x = normalize(cross(up, direction));
    vec<3, T> y = cross(direction, x);
    T wx = -dot(eye_pos, x);
    T wy = -dot(eye_pos, y);
    T wz = -dot(eye_pos, direction);
    return mat<4, 4, T> { { x[0], y[0], direction[0], zero<T> },
                          { x[1], y[1], direction[1], zero<T> },
                          { x[2], y[2], direction[2], zero<T> },
                          { wx, wy, wz, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>>
look_to_rh(const vec<3, T>& eye_pos, const vec<3, T>& direction, const vec<3, T>& up) noexcept
{
    vec<3, T> x = normalize(cross(direction, up));
    vec<3, T> y = cross(x, direction);
    T wx = -dot(eye_pos, x);
    T wy = -dot(eye_pos, y);
    T wz = dot(eye_pos, direction);
    return mat<4, 4, T> { { x[0], y[0], -direction[0], zero<T> },
                          { x[1], y[1], -direction[1], zero<T> },
                          { x[2], y[2], -direction[2], zero<T> },
                          { wx, wy, wz, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>>
look_at_lh(const vec<3, T>& eye_pos, const vec<3, T>& focus_pos, const vec<3, T>& up) noexcept
{
    return look_to_lh(eye_pos, normalize(focus_pos - eye_pos), up);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>>
look_at_rh(const vec<3, T>& eye_pos, const vec<3, T>& focus_pos, const vec<3, T>& up) noexcept
{
    return look_to_rh(eye_pos, normalize(focus_pos - eye_pos), up);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> perspective_lh(T fov_radians, T aspect, T znear,
                                                                                      T zfar) noexcept
{
    T ys = one<T> / tan(fov_radians * static_cast<T>(0.5));
    T xs = ys / aspect;
    T zs = zfar / (znear - zfar);
    return mat<4, 4, T> { { xs, zero<T>, zero<T>, zero<T> },
                          { zero<T>, ys, zero<T>, zero<T> },
                          { zero<T>, zero<T>, -zs, one<T> },
                          { zero<T>, zero<T>, znear * zs, zero<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> perspective_rh(T fov_radians, T aspect, T znear,
                                                                                      T zfar) noexcept
{
    T ys = one<T> / tan(fov_radians * static_cast<T>(0.5));
    T xs = ys / aspect;
    T zs = zfar / (znear - zfar);
    return mat<4, 4, T> { { xs, zero<T>, zero<T>, zero<T> },
                          { zero<T>, ys, zero<T>, zero<T> },
                          { zero<T>, zero<T>, zs, one<T> },
                          { zero<T>, zero<T>, znear * (-zs), zero<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> ortho_lh(T left, T right, T top, T bottom,
                                                                                T znear, T zfar) noexcept
{
    T dx = right - left;
    T dy = top - bottom;
    T dz = zfar - znear;
    return mat<4, 4, T> { { static_cast<T>(2) / dx, zero<T>, zero<T>, zero<T> },
                          { zero<T>, static_cast<T>(2) / dy, zero<T>, zero<T> },
                          { zero<T>, zero<T>, one<T> / dz, zero<T> },
                          { (right + left) / (-dx), (top + bottom) / (-dy), znear / (-dz), one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> ortho_rh(T left, T right, T top, T bottom,
                                                                                T znear, T zfar) noexcept
{
    T dx = right - left;
    T dy = top - bottom;
    T dz = zfar - znear;
    return mat<4, 4, T> { { static_cast<T>(2) / dx, zero<T>, zero<T>, zero<T> },
                          { zero<T>, static_cast<T>(2) / dy, zero<T>, zero<T> },
                          { zero<T>, zero<T>, one<T> / (-dz), zero<T> },
                          { (right + left) / (-dx), (top + bottom) / (-dy), znear / (-dz), one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> frustum_lh(T left, T right, T top, T bottom,
                                                                                  T znear, T zfar) noexcept
{
    T tow_near = static_cast<T>(2) * znear;
    T dx = right - left;
    T dy = top - bottom;
    T zs = zfar / (znear - zfar);
    return mat<4, 4, T> { { tow_near / dx, zero<T>, zero<T>, zero<T> },
                          { zero<T>, tow_near / dy, zero<T>, zero<T> },
                          { (right + left) / (-dx), (top + bottom) / (-dy), -zs, one<T> },
                          { zero<T>, zero<T>, znear * zs, zero<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> frustum_rh(T left, T right, T top, T bottom,
                                                                                  T znear, T zfar) noexcept
{
    T tow_near = static_cast<T>(2) * znear;
    T dx = right - left;
    T dy = top - bottom;
    T zs = zfar / (znear - zfar);
    return mat<4, 4, T> { { tow_near / dx, zero<T>, zero<T>, zero<T> },
                          { zero<T>, tow_near / dy, zero<T>, zero<T> },
                          { (right + left) / dx, (top + bottom) / dy, zs, -one<T> },
                          { zero<T>, zero<T>, znear * zs, zero<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate3d_x(T angle) noexcept
{
    T cos_theta = cos(angle);
    T sin_theta = sin(angle);
    return mat<4, 4, T> { { one<T>, zero<T>, zero<T>, zero<T> },
                          { zero<T>, cos_theta, sin_theta, zero<T> },
                          { zero<T>, -sin_theta, cos_theta, zero<T> },
                          { zero<T>, zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate3d_y(T angle) noexcept
{
    T cos_theta = cos(angle);
    T sin_theta = sin(angle);
    return mat<4, 4, T> { { cos_theta, zero<T>, -sin_theta, zero<T> },
                          { zero<T>, one<T>, zero<T>, zero<T> },
                          { sin_theta, zero<T>, cos_theta, zero<T> },
                          { zero<T>, zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate3d_z(T angle) noexcept
{
    T cos_theta = cos(angle);
    T sin_theta = sin(angle);
    return mat<4, 4, T> { { cos_theta, sin_theta, zero<T>, zero<T> },
                          { -sin_theta, cos_theta, zero<T>, zero<T> },
                          { zero<T>, zero<T>, one<T>, zero<T> },
                          { zero<T>, zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate3d_axis(T angle,
                                                                                     const vec<3, T>& axis) noexcept
{
    mat<4, 4, T> ret;
    detail::matrix_transform3d_implement::rotate3d_normal(ret, sin(angle), cos(angle), axis, 0);
    return ret;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate3d_from_to(const vec<3, T>& from,
                                                                                        const vec<3, T>& to) noexcept
{
    T cos_theta = dot(from, to);
    T sin_theta = sqrt(one<T> - cos_theta * cos_theta);
    mat<4, 4, T> ret;
    detail::matrix_transform3d_implement::rotate3d_normal(ret, sin_theta, cos_theta, normalize(cross(from, to)), 0);
    return ret;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>>
rotate3d_any_axis(T angle, const vec<3, T>& axis_start, const vec<3, T>& axis) noexcept
{
    mat<4, 4, T> ret;
    detail::matrix_transform3d_implement::rotate3d_normal(ret, sin(angle), cos(angle), axis, axis_start);
    return ret;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> translate3d(const vec<3, T>& v) noexcept
{
    return mat<4, 4, T> { { one<T>, zero<T>, zero<T>, zero<T> },
                          { zero<T>, one<T>, zero<T>, zero<T> },
                          { zero<T>, zero<T>, one<T>, zero<T> },
                          { v[0], v[1], v[2], one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> scale3d(const vec<3, T>& v) noexcept
{
    return mat<4, 4, T> { { v[0], zero<T>, zero<T>, zero<T> },
                          { zero<T>, v[1], zero<T>, zero<T> },
                          { zero<T>, zero<T>, v[2], zero<T> },
                          { zero<T>, zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> shear3d_x(T angle_y, T angle_z) noexcept
{
    return mat<4, 4, T> { { one<T>, tan(angle_y), tan(angle_z), zero<T> },
                          { zero<T>, one<T>, zero<T>, zero<T> },
                          { zero<T>, zero<T>, one<T>, zero<T> },
                          { zero<T>, zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> shear3d_y(T angle_x, T angle_z) noexcept
{
    return mat<4, 4, T> { { one<T>, zero<T>, zero<T>, zero<T> },
                          { tan(angle_x), one<T>, tan(angle_z), zero<T> },
                          { zero<T>, zero<T>, one<T>, zero<T> },
                          { zero<T>, zero<T>, zero<T>, one<T> } };
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> shear3d_z(T angle_x, T angle_y) noexcept
{
    return mat<4, 4, T> { { one<T>, zero<T>, zero<T>, zero<T> },
                          { zero<T>, one<T>, zero<T>, zero<T> },
                          { tan(angle_x), tan(angle_y), one<T>, zero<T> },
                          { zero<T>, zero<T>, zero<T>, one<T> } };
}

} // namespace ktm

#include "../../detail/function/matrix_transform3d.inl"

#endif