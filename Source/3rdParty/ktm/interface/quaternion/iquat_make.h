//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_QUAT_MAKE_H_
#define _KTM_I_QUAT_MAKE_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/quat_fwd.h"
#include "../../type/mat_fwd.h"
#include "../../function/common.h"
#include "../../function/geometric.h"
#include "../../function/matrix.h"

namespace ktm
{

template <class Father, class Child>
struct iquat_make;

template <class Father, typename T>
struct iquat_make<Father, quat<T>> : Father
{
    using Father::Father;

    static KTM_INLINE quat<T> identity() noexcept { return quat<T>(zero<T>, zero<T>, zero<T>, one<T>); }

    static KTM_INLINE quat<T> real_imag(T real, const vec<3, T>& imag) noexcept
    {
        return quat<T>(imag.x, imag.y, imag.z, real);
    }

    static KTM_INLINE quat<T> angle_axis(T angle, const vec<3, T>& axis) noexcept
    {
        T half_angle = angle * static_cast<T>(0.5);
        T sin_half_angle = sin(half_angle);
        return quat<T>(sin_half_angle * axis[0], sin_half_angle * axis[1], sin_half_angle * axis[2], cos(half_angle));
    }

    static KTM_INLINE quat<T> from_angle_x(T angle) noexcept
    {
        T half_angle = angle * static_cast<T>(0.5);
        return quat<T>(sin(half_angle), zero<T>, zero<T>, cos(half_angle));
    }

    static KTM_INLINE quat<T> from_angle_y(T angle) noexcept
    {
        T half_angle = angle * static_cast<T>(0.5);
        return quat<T>(zero<T>, sin(half_angle), zero<T>, cos(half_angle));
    }

    static KTM_INLINE quat<T> from_angle_z(T angle) noexcept
    {
        T half_angle = angle * static_cast<T>(0.5);
        return quat<T>(zero<T>, zero<T>, sin(half_angle), cos(half_angle));
    }

    static KTM_NOINLINE quat<T> from_to(const vec<3, T>& from, const vec<3, T>& to) noexcept
    {
        if (dot(from, to) >= 0)
            return from_to_less_half_pi(from, to);

        vec<3, T> half = from + to;

        constexpr T length_squared_epsilon = std::is_same_v<T, float> ? 0x1p-46f : 0x1p-104;
        if (length_squared(half) < length_squared_epsilon)
        {
            vec<3, T> abs_from = abs(from);
            if (abs_from.x <= abs_from.y && abs_from.x <= abs_from.z)
                return real_imag(zero<T>, normalize(cross(from, vec<3, T>(one<T>, zero<T>, zero<T>))));
            else if (abs_from.y <= abs_from.z)
                return real_imag(zero<T>, normalize(cross(from, vec<3, T>(zero<T>, one<T>, zero<T>))));
            else
                return real_imag(zero<T>, normalize(cross(from, vec<3, T>(zero<T>, zero<T>, one<T>))));
        }

        half = normalize(half);
        return from_to_less_half_pi(from, half) * from_to_less_half_pi(half, to);
    }

    static KTM_INLINE quat<T> from_matrix(const mat<4, 4, T>& m) noexcept
    {
        return from_matrix(reinterpret_cast<const mat<3, 3, T>&>(m));
    }

    static KTM_NOINLINE quat<T> from_matrix(const mat<3, 3, T>& m) noexcept
    {
        T m_trace = trace(m);
        if (m_trace >= zero<T>)
        {
            T r = static_cast<T>(2) * sqrt(one<T> + m_trace);
            T rinv = one<T> / r;
            return quat<T>(rinv * (m[1][2] - m[2][1]), rinv * (m[2][0] - m[0][2]), rinv * (m[0][1] - m[1][0]),
                           r / static_cast<T>(4));
        }
        else if (m[0][0] >= m[1][1] && m[0][0] >= m[2][2])
        {
            T r = static_cast<T>(2) * sqrt(one<T> - m[1][1] - m[2][2] + m[0][0]);
            T rinv = one<T> / r;
            return quat<T>(r / static_cast<T>(4), rinv * (m[0][1] + m[1][0]), rinv * (m[0][2] + m[2][0]),
                           rinv * (m[1][2] - m[2][1]));
        }
        else if (m[1][1] >= m[2][2])
        {
            T r = static_cast<T>(2) * sqrt(one<T> - m[0][0] - m[2][2] + m[1][1]);
            T rinv = one<T> / r;
            return quat<T>(rinv * (m[0][1] + m[1][0]), r / static_cast<T>(4), rinv * (m[1][2] + m[2][1]),
                           rinv * (m[2][0] - m[0][2]));
        }
        else
        {
            T r = static_cast<T>(2) * sqrt(one<T> - m[0][0] - m[1][1] + m[2][2]);
            T rinv = one<T> / r;
            return quat<T>(rinv * (m[0][2] + m[2][0]), rinv * (m[1][2] + m[2][1]), r / static_cast<T>(4),
                           rinv * (m[0][1] - m[1][0]));
        }
    }

    static KTM_INLINE quat<T> look_to_lh(const vec<3, T>& direction, const vec<3, T>& up) noexcept
    {
        mat<3, 3, T> m;
        m[2] = direction;
        m[0] = normalize(cross(up, m[2]));
        m[1] = cross(m[2], m[0]);
        return from_matrix(m);
    }

    static KTM_INLINE quat<T> look_to_rh(const vec<3, T>& direction, const vec<3, T>& up) noexcept
    {
        return look_to_lh(-direction, up);
    }

private:
    static KTM_INLINE quat<T> from_to_less_half_pi(const vec<3, T>& from, const vec<3, T>& to) noexcept
    {
        // calculate quaternions with rotation angles less than half pi
        vec<3, T> half = normalize(from + to);
        return real_imag(dot(from, half), cross(from, half));
    }
};

} // namespace ktm

#endif