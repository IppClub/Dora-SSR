//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_ALGEBRA_INL_
#define _KTM_MATRIX_ALGEBRA_INL_

#include <utility>
#include "matrix_algebra_fwd.h"
#include "../../setup.h"
#include "../../type/basic.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

template <size_t Row, size_t Col, typename T, typename Void>
struct ktm::detail::matrix_algebra_implement::transpose
{
    using M = mat<Row, Col, T>;
    using RetM = mat<Col, Row, T>;
    using RowV = vec<Row, T>;

    static KTM_INLINE RetM call(const M& m) noexcept
    {
        if constexpr (Row <= 4 && Col <= 4)
            return call(m, std::make_index_sequence<Row>());
        else
        {
            RetM ret;
            for (int i = 0; i < Row; ++i)
                for (int j = 0; j < Col; ++j)
                    ret[j][i] = m[i][j];
            return ret;
        }
    }

private:
    template <size_t... Ns>
    static KTM_INLINE RetM call(const M& m, std::index_sequence<Ns...>) noexcept
    {
        return RetM::from_row(m[Ns]...);
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::matrix_algebra_implement::diagonal
{
    using M = mat<N, N, T>;
    using ColV = vec<N, T>;

    static KTM_INLINE ColV call(const M& m) noexcept
    {
        ColV ret;
        if constexpr (N <= 4)
            call(ret, m, std::make_index_sequence<N>());
        else
        {
            for (int i = 0; i < N; ++i)
                ret[i] = m[i][i];
        }
        return ret;
    }

private:
    template <size_t... Ns>
    static KTM_INLINE void call(ColV& ret, const M& m, std::index_sequence<Ns...>) noexcept
    {
        ((ret[Ns] = m[Ns][Ns]), ...);
    }
};

template <typename T>
struct ktm::detail::matrix_algebra_implement::determinant<2, T>
{
    using M = mat<2, 2, T>;

    static KTM_INLINE T call(const M& m) noexcept { return m[0][0] * m[1][1] - m[1][0] * m[0][1]; }
};

template <typename T>
struct ktm::detail::matrix_algebra_implement::determinant<3, T>
{
    using M = mat<3, 3, T>;

    static KTM_INLINE T call(const M& m) noexcept
    {
        return m[0][0] * (m[1][1] * m[2][2] - m[2][1] * m[1][2]) + m[1][0] * (m[2][1] * m[0][2] - m[0][1] * m[2][2]) +
               m[2][0] * (m[0][1] * m[1][2] - m[1][1] * m[0][2]);
    }
};

template <typename T>
struct ktm::detail::matrix_algebra_implement::determinant<4, T>
{
    using M = mat<4, 4, T>;

    static KTM_INLINE T call(const M& m) noexcept
    {
        T d00 = m[2][2] * m[3][3] - m[3][2] * m[2][3];
        T d01 = m[3][2] * m[1][3] - m[1][2] * m[3][3];
        T d02 = m[1][2] * m[2][3] - m[2][2] * m[1][3];
        T r0 = m[1][1] * d00 + m[2][1] * d01 + m[3][1] * d02;
        T r1 = m[1][0] * d00 + m[2][0] * d01 + m[3][0] * d02;

        T d10 = m[2][0] * m[3][1] - m[3][0] * m[2][1];
        T d11 = m[3][0] * m[1][1] - m[1][0] * m[3][1];
        T d12 = m[1][0] * m[2][1] - m[2][0] * m[1][1];
        T r2 = m[1][3] * d10 + m[2][3] * d11 + m[3][3] * d12;
        T r3 = m[1][2] * d10 + m[2][2] * d11 + m[3][2] * d12;

        return m[0][0] * r0 - m[0][1] * r1 + m[0][2] * r2 - m[0][3] * r3;
    }
};

template <size_t N, typename T>
struct ktm::detail::matrix_algebra_implement::determinant<N, T,
                                                          std::enable_if_t<std::is_floating_point_v<T> && (N > 4)>>
{
    using M = mat<N, N, T>;

    static KTM_NOINLINE T call(const M& m) noexcept
    {
        T det = one<T>;
        M a { m };
        for (int i = 0; i < N - 1; ++i)
        {
            T recip_diag = recip(a[i][i]);
            for (int j = i + 1; j < N; ++j)
            {
                T factor = a[j][i] * recip_diag;
                for (int k = i + 1; k < N; ++k)
                {
                    a[j][k] -= a[i][k] * factor;
                }
            }
        }
        for (int i = 0; i < N; ++i)
            det *= a[i][i];
        return det;
    }
};

template <size_t N, typename T>
struct ktm::detail::matrix_algebra_implement::determinant<N, T,
                                                          std::enable_if_t<!std::is_floating_point_v<T> && (N > 4)>>
{
    using M = mat<N, N, T>;

    static KTM_NOINLINE T call(const M& m) noexcept
    {
        T det = zero<T>;
        for (int i = 0; i < N; ++i)
        {
            mat<N - 1, N - 1, T> sub_matrix;
            for (int col = 1; col < N; ++col)
            {
                for (int row = 0, sub_row = 0; row < N; ++row)
                {
                    if (row == i)
                        continue;
                    sub_matrix[col - 1][sub_row] = m[col][row];
                    ++sub_row;
                }
            }
            T sub_det = m[0][i] * determinant<N - 1, T>::call(sub_matrix);
            det += i & 0x1 ? -sub_det : sub_det;
        }
        return det;
    }
};

template <typename T>
struct ktm::detail::matrix_algebra_implement::inverse<2, T>
{
    using M = mat<2, 2, T>;

    static KTM_INLINE M call(const M& m) noexcept
    {
        T recip_det = one<T> / determinant<2, T>::call(m);
        M ret;
        ret[0][0] = m[1][1] * recip_det;
        ret[0][1] = -m[0][1] * recip_det;
        ret[1][0] = -m[1][0] * recip_det;
        ret[1][1] = m[0][0] * recip_det;
        return ret;
    }
};

template <typename T>
struct ktm::detail::matrix_algebra_implement::inverse<3, T>
{
    using M = mat<3, 3, T>;

    static KTM_INLINE M call(const M& m) noexcept
    {
        T recip_det = one<T> / determinant<3, T>::call(m);
        M ret;
        ret[0][0] = recip_det * (m[1][1] * m[2][2] - m[2][1] * m[1][2]);
        ret[0][1] = recip_det * (m[2][1] * m[0][2] - m[0][1] * m[2][2]);
        ret[0][2] = recip_det * (m[0][1] * m[1][2] - m[1][1] * m[0][2]);
        ret[1][0] = recip_det * (m[2][0] * m[1][2] - m[1][0] * m[2][2]);
        ret[1][1] = recip_det * (m[0][0] * m[2][2] - m[2][0] * m[0][2]);
        ret[1][2] = recip_det * (m[1][0] * m[0][2] - m[0][0] * m[1][2]);
        ret[2][0] = recip_det * (m[1][0] * m[2][1] - m[2][0] * m[1][1]);
        ret[2][1] = recip_det * (m[2][0] * m[0][1] - m[0][0] * m[2][1]);
        ret[2][2] = recip_det * (m[0][0] * m[1][1] - m[1][0] * m[0][1]);
        return ret;
    }
};

template <typename T>
struct ktm::detail::matrix_algebra_implement::inverse<4, T>
{
    using M = mat<4, 4, T>;

    static KTM_INLINE M call(const M& m) noexcept
    {
        T recip_det = one<T> / determinant<4, T>::call(m);
        M ret;
        ret[0][0] =
            recip_det * (m[1][1] * m[2][2] * m[3][3] - m[1][1] * m[2][3] * m[3][2] - m[2][1] * m[1][2] * m[3][3] +
                         m[2][1] * m[1][3] * m[3][2] + m[3][1] * m[1][2] * m[2][3] - m[3][1] * m[1][3] * m[2][2]);
        ret[0][1] =
            recip_det * (m[3][1] * m[0][3] * m[2][2] - m[3][1] * m[0][2] * m[2][3] - m[2][1] * m[0][3] * m[3][2] +
                         m[2][1] * m[0][2] * m[3][3] + m[0][1] * m[2][3] * m[3][2] - m[0][1] * m[2][2] * m[3][3]);
        ret[0][2] =
            recip_det * (m[0][1] * m[1][2] * m[3][3] - m[0][1] * m[1][3] * m[3][2] - m[1][1] * m[0][2] * m[3][3] +
                         m[1][1] * m[0][3] * m[3][2] + m[3][1] * m[0][2] * m[1][3] - m[3][1] * m[0][3] * m[1][2]);
        ret[0][3] =
            recip_det * (m[2][1] * m[0][3] * m[1][2] - m[2][1] * m[0][2] * m[1][3] - m[1][1] * m[0][3] * m[2][2] +
                         m[1][1] * m[0][2] * m[2][3] + m[0][1] * m[1][3] * m[2][2] - m[0][1] * m[1][2] * m[2][3]);
        ret[1][0] =
            recip_det * (m[3][0] * m[1][3] * m[2][2] - m[3][0] * m[1][2] * m[2][3] - m[2][0] * m[1][3] * m[3][2] +
                         m[2][0] * m[1][2] * m[3][3] + m[1][0] * m[2][3] * m[3][2] - m[1][0] * m[2][2] * m[3][3]);
        ret[1][1] =
            recip_det * (m[0][0] * m[2][2] * m[3][3] - m[0][0] * m[2][3] * m[3][2] - m[2][0] * m[0][2] * m[3][3] +
                         m[2][0] * m[0][3] * m[3][2] + m[3][0] * m[0][2] * m[2][3] - m[3][0] * m[0][3] * m[2][2]);
        ret[1][2] =
            recip_det * (m[3][0] * m[0][3] * m[1][2] - m[3][0] * m[0][2] * m[1][3] - m[1][0] * m[0][3] * m[3][2] +
                         m[1][0] * m[0][2] * m[3][3] + m[0][0] * m[1][3] * m[3][2] - m[0][0] * m[1][2] * m[3][3]);
        ret[1][3] =
            recip_det * (m[0][0] * m[1][2] * m[2][3] - m[0][0] * m[1][3] * m[2][2] - m[1][0] * m[0][2] * m[2][3] +
                         m[1][0] * m[0][3] * m[2][2] + m[2][0] * m[0][2] * m[1][3] - m[2][0] * m[0][3] * m[1][2]);
        ret[2][0] =
            recip_det * (m[1][0] * m[2][1] * m[3][3] - m[1][0] * m[2][3] * m[3][1] - m[2][0] * m[1][1] * m[3][3] +
                         m[2][0] * m[1][3] * m[3][1] + m[3][0] * m[1][1] * m[2][3] - m[3][0] * m[1][3] * m[2][1]);
        ret[2][1] =
            recip_det * (m[3][0] * m[0][3] * m[2][1] - m[3][0] * m[0][1] * m[2][3] - m[2][0] * m[0][3] * m[3][1] +
                         m[2][0] * m[0][1] * m[3][3] + m[0][0] * m[2][3] * m[3][1] - m[0][0] * m[2][1] * m[3][3]);
        ret[2][2] =
            recip_det * (m[0][0] * m[1][1] * m[3][3] - m[0][0] * m[1][3] * m[3][1] - m[1][0] * m[0][1] * m[3][3] +
                         m[1][0] * m[0][3] * m[3][1] + m[3][0] * m[0][1] * m[1][3] - m[3][0] * m[0][3] * m[1][1]);
        ret[2][3] =
            recip_det * (m[2][0] * m[0][3] * m[1][1] - m[2][0] * m[0][1] * m[1][3] - m[1][0] * m[0][3] * m[2][1] +
                         m[1][0] * m[0][1] * m[2][3] + m[0][0] * m[1][3] * m[2][1] - m[0][0] * m[1][1] * m[2][3]);
        ret[3][0] =
            recip_det * (m[3][0] * m[1][2] * m[2][1] - m[3][0] * m[1][1] * m[2][2] - m[2][0] * m[1][2] * m[3][1] +
                         m[2][0] * m[1][1] * m[3][2] + m[1][0] * m[2][2] * m[3][1] - m[1][0] * m[2][1] * m[3][2]);
        ret[3][1] =
            recip_det * (m[0][0] * m[2][1] * m[3][2] - m[0][0] * m[2][2] * m[3][1] - m[2][0] * m[0][1] * m[3][2] +
                         m[2][0] * m[0][2] * m[3][1] + m[3][0] * m[0][1] * m[2][2] - m[3][0] * m[0][2] * m[2][1]);
        ret[3][2] =
            recip_det * (m[3][0] * m[0][2] * m[1][1] - m[3][0] * m[0][1] * m[1][2] - m[1][0] * m[0][2] * m[3][1] +
                         m[1][0] * m[0][1] * m[3][2] + m[0][0] * m[1][2] * m[3][1] - m[0][0] * m[1][1] * m[3][2]);
        ret[3][3] =
            recip_det * (m[0][0] * m[1][1] * m[2][2] - m[0][0] * m[1][2] * m[2][1] - m[1][0] * m[0][1] * m[2][2] +
                         m[1][0] * m[0][2] * m[2][1] + m[2][0] * m[0][1] * m[1][2] - m[2][0] * m[0][2] * m[1][1]);
        return ret;
    }
};

template <size_t N, typename T>
struct ktm::detail::matrix_algebra_implement::inverse<N, T, std::enable_if_t<(N > 4)>>
{
    using M = mat<N, N, T>;

    static KTM_NOINLINE M call(const M& m) noexcept
    {
        M left = m;
        M right = M::from_eye();

        for (int i = 0; i < N; ++i)
        {
            T recip_diag = recip(left[i][i]);
            for (int j = 0; j < N; ++j)
            {
                if (i != j)
                {
                    T factor = left[i][j] * recip_diag;
                    for (int k = 0; k < N; ++k)
                    {
                        if (k >= i)
                            left[k][j] -= factor * left[k][i];
                        right[k][j] -= factor * right[k][i];
                    }
                }
            }
            for (int k = 0; k < N; ++k)
            {
                if (k >= i)
                    left[k][i] *= recip_diag;
                right[k][i] *= recip_diag;
            }
        }
        return right;
    }
};

#endif
