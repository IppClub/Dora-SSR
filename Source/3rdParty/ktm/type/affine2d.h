//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_AFFINE_2D_H_
#define _KTM_AFFINE_2D_H_

#include "mat.h"
#include "comp.h"
#include "../function/common.h"
#include "../function/matrix.h"

namespace ktm
{

template <typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct affine2d
{
    union
    {
        mat<3, 2, T> m;

        struct
        {
            T a, b, c, d, tx, ty;
        };
    };

    KTM_FUNC affine2d() noexcept : a(one<T>), b(zero<T>), c(zero<T>), d(one<T>), tx(zero<T>), ty(zero<T>) {}

    KTM_FUNC affine2d(const mat<2, 2, T>& matrix) noexcept : m(matrix[0], matrix[1], vec<2, T>()) {}

    KTM_FUNC affine2d(const mat<3, 3, T>& matrix) noexcept : m(matrix[0].xy(), matrix[1].xy(), matrix[2].xy()) {}

    KTM_FUNC affine2d(const mat<4, 4, T>& matrix) noexcept : m(matrix[0].xy(), matrix[1].xy(), matrix[3].xy()) {}

    KTM_INLINE affine2d& translate(T x, T y) noexcept
    {
        m[2] += m[0] * x + m[1] * y;
        return *this;
    }

    KTM_INLINE affine2d& translate(const vec<2, T>& v) noexcept { return translate(v[0], v[1]); }

    KTM_INLINE affine2d& rotate(const comp<T>& c) noexcept
    {
        vec<2, T> tmp = m[0];
        m[0] = tmp * c[1] + m[1] * c[0];
        m[1] = m[1] * c[1] - tmp * c[0];
        return *this;
    }

    KTM_INLINE affine2d& rotate(T angle) noexcept { return rotate(comp<T>::from_angle(angle)); }

    KTM_INLINE affine2d& scale(T x, T y) noexcept
    {
        m[0] *= x;
        m[1] *= y;
        return *this;
    }

    KTM_INLINE affine2d& scale(const vec<2, T>& v) noexcept { return scale(v[0], v[1]); }

    KTM_INLINE affine2d& shear_x(T angle) noexcept
    {
        m[1] += m[0] * tan(angle);
        return *this;
    }

    KTM_INLINE affine2d& shear_y(T angle) noexcept
    {
        m[0] += m[1] * tan(angle);
        return *this;
    }

    KTM_INLINE affine2d& concat(const affine2d& affine) noexcept
    {
        return translate(affine.tx, affine.ty).concat(reinterpret_cast<const mat<2, 2, T>&>(affine.m));
    }

    KTM_INLINE affine2d& concat(const mat<2, 2, T>& matrix) noexcept
    {
        mat<2, 2, T>& m_ref = reinterpret_cast<mat<2, 2, T>&>(m);
        m_ref = m_ref * matrix;
        return *this;
    }

    KTM_INLINE affine2d& concat(const mat<3, 3, T>& matrix) noexcept
    {
        return translate(matrix[2][0], matrix[2][1]).concat(mat<2, 2, T>(matrix[0].xy(), matrix[1].xy()));
    }

    KTM_INLINE affine2d& invert() noexcept
    {
        mat<2, 2, T>& m_ref = reinterpret_cast<mat<2, 2, T>&>(m);
        m_ref = inverse(m_ref);
        m[2] = m_ref * -m[2];
        return *this;
    }

    KTM_INLINE affine2d& matrix2x2(mat<2, 2, T>& out_matrix) noexcept
    {
        out_matrix2x2(out_matrix);
        return *this;
    }

    KTM_INLINE affine2d& matrix3x3(mat<3, 3, T>& out_matrix) noexcept
    {
        out_matrix3x3(out_matrix);
        return *this;
    }

    KTM_INLINE affine2d& matrix4x4(mat<4, 4, T>& out_matrix) noexcept
    {
        out_matrix4x4(out_matrix);
        return *this;
    }

    KTM_INLINE const affine2d& matrix2x2(mat<2, 2, T>& out_matrix) const noexcept
    {
        out_matrix2x2(out_matrix);
        return *this;
    }

    KTM_INLINE const affine2d& matrix3x3(mat<3, 3, T>& out_matrix) const noexcept
    {
        out_matrix3x3(out_matrix);
        return *this;
    }

    KTM_INLINE const affine2d& matrix4x4(mat<4, 4, T>& out_matrix) const noexcept
    {
        out_matrix4x4(out_matrix);
        return *this;
    }

    KTM_FUNC affine2d& operator<<(const affine2d& affine) noexcept { return concat(affine); }

    KTM_FUNC affine2d& operator<<(const mat<2, 2, T>& matrix) noexcept { return concat(matrix); }

    KTM_FUNC affine2d& operator<<(const mat<3, 3, T>& matrix) noexcept { return concat(matrix); }

    KTM_FUNC affine2d& operator>>(mat<2, 2, T>& out_matrix) noexcept { return matrix2x2(out_matrix); }

    KTM_FUNC affine2d& operator>>(mat<3, 3, T>& out_matrix) noexcept { return matrix3x3(out_matrix); }

    KTM_FUNC affine2d& operator>>(mat<4, 4, T>& out_matrix) noexcept { return matrix4x4(out_matrix); }

    KTM_FUNC const affine2d& operator>>(mat<2, 2, T>& out_matrix) const noexcept { return matrix2x2(out_matrix); }

    KTM_FUNC const affine2d& operator>>(mat<3, 3, T>& out_matrix) const noexcept { return matrix3x3(out_matrix); }

    KTM_FUNC const affine2d& operator>>(mat<4, 4, T>& out_matrix) const noexcept { return matrix4x4(out_matrix); }

private:
    KTM_FUNC void out_matrix2x2(mat<2, 2, T>& out_matrix) const noexcept
    {
        out_matrix[0] = m[0];
        out_matrix[1] = m[1];
    }

    KTM_FUNC void out_matrix3x3(mat<3, 3, T>& out_matrix) const noexcept
    {
        out_matrix[0] = vec<3, T>(a, b, zero<T>);
        out_matrix[1] = vec<3, T>(c, d, zero<T>);
        out_matrix[2] = vec<3, T>(tx, ty, one<T>);
    }

    KTM_FUNC void out_matrix4x4(mat<4, 4, T>& out_matrix) const noexcept
    {
        out_matrix[0] = vec<4, T>(a, b, zero<T>, zero<T>);
        out_matrix[1] = vec<4, T>(c, d, zero<T>, zero<T>);
        out_matrix[2] = vec<4, T>(zero<T>, zero<T>, one<T>, zero<T>);
        out_matrix[3] = vec<4, T>(tx, ty, zero<T>, one<T>);
    }
};

} // namespace ktm

#endif