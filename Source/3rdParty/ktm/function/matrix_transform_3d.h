//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_TRANSFORM_3D_H_
#define _KTM_MATRIX_TRANSFORM_3D_H_

#include "../setup.h"
#include "../type/vec.h"
#include "../type/mat.h"
#include "trigonometric.h"
#include "geometric.h"

namespace ktm
{

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> look_dr_lh(const vec<3, T>& eye_pos, const vec<3, T>& direction, const vec<3, T>& up) noexcept
{
    vec<3, T> x = normalize(cross(up, direction));
    vec<3, T> y = cross(direction, x);
    T wx = -dot(eye_pos, x);
    T wy = -dot(eye_pos, y);
    T wz = -dot(eye_pos, direction);
    return mat<4, 4, T>({ x[0], y[0], direction[0], zero<T> },
                        { x[1] ,y[1], direction[1], zero<T> },
                        { x[2], y[2], direction[2], zero<T> },
                        { wx, wy, wz, one<T> });
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> look_dr_rh(const vec<3, T>& eye_pos, const vec<3, T>& direction, const vec<3, T>& up) noexcept
{
    vec<3, T> x = normalize(cross(direction, up));
    vec<3, T> y = cross(x, direction);
    T wx = -dot(eye_pos, x);
    T wy = -dot(eye_pos, y);
    T wz = dot(eye_pos, direction);
    return mat<4, 4, T>({ x[0], y[0], -direction[0], zero<T> },
                        { x[1] ,y[1], -direction[1], zero<T> },
                        { x[2], y[2], -direction[2], zero<T> },
                        { wx, wy, wz, one<T> });
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> look_at_lh(const vec<3, T>& eye_pos, const vec<3, T>& focus_pos, const vec<3, T>& up) noexcept
{
    return look_dr_lh(eye_pos, normalize(focus_pos - eye_pos), up); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> look_at_rh(const vec<3, T>& eye_pos, const vec<3, T>& focus_pos, const vec<3, T>& up) noexcept
{
    return look_dr_rh(eye_pos, normalize(focus_pos - eye_pos), up); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> perspective_lh(T fov_radians, T aspect, T znear, T zfar) noexcept
{
    T ys = one<T> / tan(fov_radians * static_cast<T>(0.5));
    T xs = ys / aspect;
    T zs = zfar / ( znear - zfar );
    return mat<4, 4, T>({ xs, zero<T>, zero<T>, zero<T> },
                        { zero<T>, ys, zero<T>, zero<T> },
                        { zero<T>, zero<T>, -zs, one<T> },
                        { zero<T>, zero<T>, znear * zs, zero<T> }); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> perspective_rh(T fov_radians, T aspect, T znear, T zfar) noexcept
{
    T ys = one<T> / tan(fov_radians * static_cast<T>(0.5));
    T xs = ys / aspect;
    T zs = zfar / ( znear - zfar );
    return mat<4, 4, T>({ xs, zero<T>, zero<T>, zero<T> },
                        { zero<T>, ys, zero<T>, zero<T> },
                        { zero<T>, zero<T>, zs, one<T> },
                        { zero<T>, zero<T>, znear * (-zs), zero<T> }); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> ortho_lh(T left, T right, T top, T bottom, T znear, T zfar) noexcept
{
    T dx = right - left;
    T dy = top - bottom;
    T dz = zfar - znear;
    return mat<4, 4, T>({ static_cast<T>(2) / dx, zero<T>, zero<T>, zero<T> },
                        { zero<T>, static_cast<T>(2) / dy, zero<T>, zero<T> },
                        { zero<T>, zero<T>, one<T> / dz, zero<T> },
                        { (right + left) / (-dx), (top + bottom) / (-dy), znear / (-dz), one<T>});
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> ortho_rh(T left, T right, T top, T bottom, T znear, T zfar) noexcept
{
    T dx = right - left;
    T dy = top - bottom;
    T dz = zfar - znear;
    return mat<4, 4, T>({ static_cast<T>(2) / dx, zero<T>, zero<T>, zero<T> },
                        { zero<T>, static_cast<T>(2) / dy, zero<T>, zero<T> },
                        { zero<T>, zero<T>, one<T> / (-dz), zero<T> },
                        { (right + left) / (-dx), (top + bottom) / (-dy), znear / (-dz), one<T>});
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> frustum_lh(T left, T right, T top, T bottom, T znear, T zfar) noexcept
{
    T tow_near = static_cast<T>(2) * znear;
    T dx = right - left;
    T dy = top - bottom;
    T zs = zfar / ( znear - zfar );
    return mat<4, 4, T>({ tow_near / dx, zero<T>, zero<T>, zero<T> },
                        { zero<T>, tow_near / dy, zero<T>, zero<T> },
                        { (right + left) / (-dx), (top + bottom) / (-dy), -zs, one<T> },
                        { zero<T>, zero<T>, znear * zs, zero<T>});
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> frustum_rh(T left, T right, T top, T bottom, T znear, T zfar) noexcept
{
    T tow_near = static_cast<T>(2) * znear;
    T dx = right - left;
    T dy = top - bottom;
    T zs = zfar / ( znear - zfar );
    return mat<4, 4, T>({ tow_near / dx, zero<T>, zero<T>, zero<T> },
                        { zero<T>, tow_near / dy, zero<T>, zero<T> },
                        { (right + left) / dx, (top + bottom) / dy, zs, -one<T> },
                        { zero<T>, zero<T>, znear * zs, zero<T>});
}

namespace detail
{
namespace transform_3d_implement
{
template<typename T>
KTM_NOINLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate_normal(T sin_theta, T cos_theta, const vec<3, T>& normal, const vec<3, T>* normal_start_ptr = nullptr) noexcept
{
	T one_minus_cos_theta = one<T> - cos_theta;
    T xx_one_minus_cos = normal[0] * normal[0] * one_minus_cos_theta;
    T xy_one_minus_cos = normal[0] * normal[1] * one_minus_cos_theta;
    T xz_one_minus_cos = normal[0] * normal[2] * one_minus_cos_theta;
    T yy_one_minus_cos = normal[1] * normal[1] * one_minus_cos_theta;
    T yz_one_minus_cos = normal[1] * normal[2] * one_minus_cos_theta;
    T zz_one_minus_cos = normal[2] * normal[2] * one_minus_cos_theta;
    T x_sin = normal[0] * sin_theta, y_sin = normal[1] * sin_theta, z_sin = normal[2] * sin_theta;
    mat<4, 4, T> ret;
    ret[0] = { xx_one_minus_cos + cos_theta, xy_one_minus_cos + z_sin, xz_one_minus_cos - y_sin, zero<T> };
    ret[1] = { xy_one_minus_cos - z_sin, yy_one_minus_cos + cos_theta, yz_one_minus_cos + x_sin, zero<T> };
    ret[2] = { xz_one_minus_cos + y_sin, yz_one_minus_cos - x_sin, zz_one_minus_cos + cos_theta, zero<T> };
    if(normal_start_ptr)
    {
        T a = (*normal_start_ptr)[0], b = (*normal_start_ptr)[1], c = (*normal_start_ptr)[2]; 
        ret[3] = { a * (one_minus_cos_theta - xx_one_minus_cos) + b * (z_sin - xy_one_minus_cos) - c * (y_sin + xz_one_minus_cos),
                   b * (one_minus_cos_theta - yy_one_minus_cos) + c * (x_sin - yz_one_minus_cos) - a * (z_sin + xy_one_minus_cos),
                   c * (one_minus_cos_theta - zz_one_minus_cos) + a * (y_sin - xz_one_minus_cos) - b * (x_sin + yz_one_minus_cos),
                   one<T> }; 
    }
    else 
    {
        ret[3] = { zero<T>, zero<T>, zero<T>, one<T> }; 
    }
    return ret;
}
}
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate_axis(T angle, const vec<3, T>& axis) noexcept
{
	return detail::transform_3d_implement::rotate_normal(sin(angle), cos(angle), axis);
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate_axis_x(T angle) noexcept
{
    T cos_theta = cos(angle);
    T sin_theta = sin(angle);
    return mat<4, 4, T>({ one<T>, zero<T>, zero<T>, zero<T> },
                        { zero<T>, cos_theta, sin_theta, zero<T> },
                        { zero<T>, -sin_theta, cos_theta, zero<T> },
                        { zero<T>, zero<T>, zero<T>, one<T> });
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate_axis_y(T angle) noexcept
{
    T cos_theta = cos(angle);
    T sin_theta = sin(angle);
    return mat<4, 4, T>({ cos_theta, zero<T>, -sin_theta, zero<T> },
                        { zero<T>, one<T>, zero<T>, zero<T> },
                        { sin_theta, zero<T>, cos_theta, zero<T> },
                        { zero<T>, zero<T>, zero<T>, one<T> });
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate_axis_z(T angle) noexcept
{
    T cos_theta = cos(angle);
    T sin_theta = sin(angle);
    return mat<4, 4, T>({ cos_theta, sin_theta, zero<T>, zero<T> },
                        { -sin_theta, cos_theta, zero<T>, zero<T> },
                        { zero<T>, zero<T>, one<T>, zero<T> },
                        { zero<T>, zero<T>, zero<T>, one<T> });
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate_from_to(const vec<3, T>& from, const vec<3, T>& to) noexcept
{
    T cos_theta = dot(from, to);
    T sin_theta = sqrt(one<T> - cos_theta * cos_theta);
	return detail::transform_3d_implement::rotate_normal(sin_theta, cos_theta, normalize(cross(from, to)));
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> rotate_any_axis(T angle, const vec<3, T>& axis_start, const vec<3, T>& axis) noexcept
{
	return detail::transform_3d_implement::rotate_normal(sin(angle), cos(angle), axis, &axis_start);
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> translate_3d(const vec<3, T>& v) noexcept
{
    return mat<4, 4, T>({ one<T>, zero<T>, zero<T>, zero<T> },
                        { zero<T>, one<T>, zero<T>, zero<T> },
                        { zero<T>, zero<T>, one<T>, zero<T> },
                        { v[0], v[1], v[2], one<T> });
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, mat<4, 4, T>> scale_3d(const vec<3, T>& v) noexcept
{
    return mat<4, 4, T>({ v[0], zero<T>, zero<T>, zero<T> },
                        { zero<T>, v[1], zero<T>, zero<T> },
                        { zero<T>, zero<T>, v[2], zero<T> },
                        { zero<T>, zero<T>, zero<T>, one<T> });
}

}

#endif