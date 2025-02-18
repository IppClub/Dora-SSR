//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_AFFINE_3D_H_
#define _KTM_AFFINE_3D_H_

#include "mat.h"
#include "quat.h"
#include "../function/common.h"
#include "../function/matrix.h"

namespace ktm
{

template <typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct affine3d
{
    mat<4, 3, T> m;

    KTM_FUNC affine3d() noexcept
        : m(vec<3, T>(one<T>, zero<T>, zero<T>), vec<3, T>(zero<T>, one<T>, zero<T>),
            vec<3, T>(zero<T>, zero<T>, one<T>), vec<3, T>())
    {
    }

    KTM_FUNC affine3d(const mat<3, 3, T>& matrix) noexcept : m(matrix[0], matrix[1], matrix[2], vec<3, T>()) {}

    KTM_FUNC affine3d(const mat<4, 4, T>& matrix) noexcept
        : m(matrix[0].xyz(), matrix[1].xyz(), matrix[2].xyz(), matrix[3].xyz())
    {
    }

    KTM_INLINE affine3d& translate(T x, T y, T z) noexcept
    {
        m[3] += m[0] * x + m[1] * y + m[2] * z;
        return *this;
    }

    KTM_INLINE affine3d& translate(const vec<3, T>& v) noexcept { return translate(v[0], v[1], v[2]); }

    KTM_INLINE affine3d& rotate(const quat<T>& q) noexcept
    {
        mat<3, 3, T>& m3x3_ref = reinterpret_cast<mat<3, 3, T>&>(m);
        m3x3_ref = m3x3_ref * q.matrix3x3();
        return *this;
    }

    KTM_INLINE affine3d& rotate_x(T angle) noexcept
    {
        T cos_theta = cos(angle);
        T sin_theta = sin(angle);
        vec<3, T> tmp = m[1];
        m[1] = tmp * cos_theta + m[2] * sin_theta;
        m[2] = m[2] * cos_theta - m[1] * sin_theta;
        return *this;
    }

    KTM_INLINE affine3d& rotate_y(T angle) noexcept
    {
        T cos_theta = cos(angle);
        T sin_theta = sin(angle);
        vec<3, T> tmp = m[0];
        m[0] = tmp * cos_theta - m[2] * sin_theta;
        m[2] = m[2] * cos_theta + tmp * sin_theta;
        return *this;
    }

    KTM_INLINE affine3d& rotate_z(T angle) noexcept
    {
        T cos_theta = cos(angle);
        T sin_theta = sin(angle);
        vec<3, T> tmp = m[0];
        m[0] = tmp * cos_theta + m[1] * sin_theta;
        m[1] = m[1] * cos_theta - tmp * sin_theta;
        return *this;
    }

    KTM_INLINE affine3d& rotate_axis(T angle, const vec<3, T>& axis) noexcept
    {
        mat<4, 4, T> r = rotate3d_axis(angle, axis);
        const mat<3, 3, T>& r_ref = reinterpret_cast<const mat<3, 3, T>&>(r);
        mat<3, 3, T>& m_ref = reinterpret_cast<mat<3, 3, T>&>(m);
        m_ref = m_ref * r_ref;
        return *this;
    }

    KTM_INLINE affine3d& rotate_from_to(const vec<3, T>& from, const vec<3, T>& to) noexcept
    {
        mat<4, 4, T> r = rotate3d_from_to(from, to);
        const mat<3, 3, T>& r_ref = reinterpret_cast<const mat<3, 3, T>&>(r);
        mat<3, 3, T>& m_ref = reinterpret_cast<mat<3, 3, T>&>(m);
        m_ref = m_ref * r_ref;
        return *this;
    }

    KTM_INLINE affine3d& scale(T x, T y, T z) noexcept
    {
        m[0] *= x;
        m[1] *= y;
        m[2] *= z;
        return *this;
    }

    KTM_INLINE affine3d& scale(const vec<3, T>& v) noexcept { return scale(v[0], v[1], v[2]); }

    KTM_INLINE affine3d& shear_x(T angle_y, T angle_z) noexcept
    {
        m[0] += m[1] * tan(angle_y) + m[2] * tan(angle_z);
        return *this;
    }

    KTM_INLINE affine3d& shear_y(T angle_x, T angle_z) noexcept
    {
        m[1] += m[0] * tan(angle_x) + m[2] * tan(angle_z);
        return *this;
    }

    KTM_INLINE affine3d& shear_z(T angle_x, T angle_y) noexcept
    {
        m[2] += m[0] * tan(angle_x) + m[1] * tan(angle_y);
        return *this;
    }

    KTM_INLINE affine3d& concat(const affine3d& affine) noexcept
    {
        return translate(affine.m[3]).concat(reinterpret_cast<const mat<3, 3, T>&>(affine.m));
    }

    KTM_INLINE affine3d& concat(const mat<3, 3, T>& matrix) noexcept
    {
        mat<3, 3, T>& m_ref = reinterpret_cast<mat<3, 3, T>&>(m);
        m_ref = m_ref * matrix;
        return *this;
    }

    KTM_INLINE affine3d& concat(const mat<4, 4, T>& matrix) noexcept
    {
        return translate(matrix[3].xyz()).concat(reinterpret_cast<const mat<3, 3, T>&>(matrix));
    }

    KTM_INLINE affine3d& invert() noexcept
    {
        mat<3, 3, T>& m_ref = reinterpret_cast<mat<3, 3, T>&>(m);
        m_ref = inverse(m_ref);
        m[3] = m_ref * -m[3];
        return *this;
    }

    KTM_INLINE affine3d& matrix3x3(mat<3, 3, T>& out_matrix) noexcept
    {
        out_matrix3x3(out_matrix);
        return *this;
    }

    KTM_INLINE affine3d& matrix4x4(mat<4, 4, T>& out_matrix) noexcept
    {
        out_matrix4x4(out_matrix);
        return *this;
    }

    KTM_INLINE const affine3d& matrix3x3(mat<3, 3, T>& out_matrix) const noexcept
    {
        out_matrix3x3(out_matrix);
        return *this;
    }

    KTM_INLINE const affine3d& matrix4x4(mat<4, 4, T>& out_matrix) const noexcept
    {
        out_matrix4x4(out_matrix);
        return *this;
    }

    KTM_FUNC affine3d& operator<<(const affine3d& affine) noexcept { return concat(affine); }

    KTM_FUNC affine3d& operator<<(const mat<3, 3, T>& matrix) noexcept { return concat(matrix); }

    KTM_FUNC affine3d& operator<<(const mat<4, 4, T>& matrix) noexcept { return concat(matrix); }

    KTM_FUNC affine3d& operator>>(mat<3, 3, T>& out_matrix) noexcept { return matrix3x3(out_matrix); }

    KTM_FUNC affine3d& operator>>(mat<4, 4, T>& out_matrix) noexcept { return matrix4x4(out_matrix); }

    KTM_FUNC const affine3d& operator>>(mat<3, 3, T>& out_matrix) const noexcept { return matrix3x3(out_matrix); }

    KTM_FUNC const affine3d& operator>>(mat<4, 4, T>& out_matrix) const noexcept { return matrix4x4(out_matrix); }

private:
    KTM_FUNC void out_matrix3x3(mat<3, 3, T>& out_matrix) const noexcept
    {
        out_matrix[0] = m[0];
        out_matrix[1] = m[1];
        out_matrix[2] = m[2];
    }

    KTM_FUNC void out_matrix4x4(mat<4, 4, T>& out_matrix) const noexcept
    {
        out_matrix[0] = vec<4, T>(m[0], zero<T>);
        out_matrix[1] = vec<4, T>(m[1], zero<T>);
        out_matrix[2] = vec<4, T>(m[2], zero<T>);
        out_matrix[3] = vec<4, T>(m[3], one<T>);
    }
};

} // namespace ktm

#endif