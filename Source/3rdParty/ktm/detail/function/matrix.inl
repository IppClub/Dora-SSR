//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_INL_
#define _KTM_MATRIX_INL_

#include <utility>
#include "matrix_fwd.h"
#include "../../setup.h"
#include "../../type/basic.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

template<size_t Row, size_t Col, typename T, typename Void>
struct ktm::detail::matrix_implement::transpose
{
	using M = mat<Row, Col, T>;
    using RetM = mat<Col, Row, T>;
    using RowV = vec<Row, T>;
    static KTM_INLINE RetM call(const M& m) noexcept
    {
        return call(m, std::make_index_sequence<Col>(), std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Rs, size_t ...Cs>
    static KTM_INLINE RetM call(const M& m, std::index_sequence<Rs...>, std::index_sequence<Cs...>) noexcept
    {
        RetM ret;
        size_t row_index;
        ((row_index = Rs, ret[Rs] = RowV(m[Cs][row_index]...)), ...);
        return ret;
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::matrix_implement::trace
{
    using M = mat<N, N, T>;
    static KTM_INLINE T call(const M& m) noexcept
    {
        return call(m, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE T call(const M& m, std::index_sequence<Ns...>) noexcept
    {
        return ((m[Ns][Ns])+ ...);
    }
};

template<size_t N, typename T, typename Void>
struct ktm::detail::matrix_implement::diagonal
{
    using M = mat<N, N, T>;
    using ColV = vec<N, T>;
    static KTM_INLINE ColV call(const M& m) noexcept
    {
        return call(m, std::make_index_sequence<N>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE ColV call(const M& m, std::index_sequence<Ns...>) noexcept
    {
        ColV ret;
        ((ret[Ns] = m[Ns][Ns]), ...);
        return ret;
    }
};

template<typename T>
struct ktm::detail::matrix_implement::determinant<2, T>
{
    using M = mat<2, 2, T>;
    static KTM_INLINE T call(const M& m) noexcept
    {
        return m[0][0] * m[1][1] - m[1][0] * m[0][1];
    }
};

template<typename T>
struct ktm::detail::matrix_implement::determinant<3, T>
{
    using M = mat<3, 3, T>;
    static KTM_INLINE T call(const M& m) noexcept
    {
        return m[0][0] * (m[1][1] * m[2][2] - m[2][1] * m[1][2]) +
               m[1][0] * (m[2][1] * m[0][2] - m[0][1] * m[2][2]) +
               m[2][0] * (m[0][1] * m[1][2] - m[1][1] * m[0][2]);
    }
};

template<typename T>
struct ktm::detail::matrix_implement::determinant<4, T>
{
    using M = mat<4, 4, T>;
    static KTM_INLINE T call(const M& m) noexcept
    {
        T d00 = m[2][2] * m[3][3] - m[3][2] * m[2][3];
        T d01 = m[3][2] * m[1][3] - m[1][2] * m[3][3];
        T d02 = m[1][2] * m[2][3] - m[2][2] * m[1][3];
        T r0  = m[1][1] * d00 + m[2][1] * d01 + m[3][1] * d02;
        T r1  = m[1][0] * d00 + m[2][0] * d01 + m[3][0] * d02;

        T d10 = m[2][0] * m[3][1] - m[3][0] * m[2][1];
        T d11 = m[3][0] * m[1][1] - m[1][0] * m[3][1];
        T d12 = m[1][0] * m[2][1] - m[2][0] * m[1][1];
        T r2  = m[1][3] * d10 + m[2][3] * d11 + m[3][3] * d12;
        T r3  = m[1][2] * d10 + m[2][2] * d11 + m[3][2] * d12;
                
        return m[0][0] * r0 - m[0][1] * r1 + m[0][2] * r2 - m[0][3] * r3;
    }
};

template<typename T>
struct ktm::detail::matrix_implement::inverse<2, T>
{
    using M = mat<2, 2, T>;
    static KTM_INLINE M call(const M& m) noexcept
    {
        T one_over_det = one<T> / determinant<2, T>::call(m);
        M ret;
        ret[0][0] = m[1][1] * one_over_det;
        ret[0][1] = - m[0][1] * one_over_det; 
        ret[1][0] = - m[1][0] * one_over_det; 
        ret[1][1] = m[0][0] * one_over_det;
        return ret;
    }
};

template<typename T>
struct ktm::detail::matrix_implement::inverse<3, T>
{
    using M = mat<3, 3, T>;
    static KTM_INLINE M call(const M& m) noexcept
    {
        T one_over_det = one<T> / determinant<3, T>::call(m);
        M ret;
        ret[0][0] = one_over_det * (m[1][1] * m[2][2] - m[2][1] * m[1][2]);
        ret[0][1] = one_over_det * (m[2][1] * m[0][2] - m[0][1] * m[2][2]);
        ret[0][2] = one_over_det * (m[0][1] * m[1][2] - m[1][1] * m[0][2]);
        ret[1][0] = one_over_det * (m[2][0] * m[1][2] - m[1][0] * m[2][2]);    
        ret[1][1] = one_over_det * (m[0][0] * m[2][2] - m[2][0] * m[0][2]);
        ret[1][2] = one_over_det * (m[1][0] * m[0][2] - m[0][0] * m[1][2]);
        ret[2][0] = one_over_det * (m[1][0] * m[2][1] - m[2][0] * m[1][1]);
        ret[2][1] = one_over_det * (m[2][0] * m[0][1] - m[0][0] * m[2][1]);
        ret[2][2] = one_over_det * (m[0][0] * m[1][1] - m[1][0] * m[0][1]);
        return ret;
    }
};

template<typename T>
struct ktm::detail::matrix_implement::inverse<4, T>
{
    using M = mat<4, 4, T>;
    static KTM_INLINE M call(const M& m) noexcept
    {
        T one_over_det = one<T> / determinant<4, T>::call(m);
        M ret;
        ret[0][0] =
            one_over_det * (m[1][1] * m[2][2] * m[3][3] - m[1][1] * m[2][3] * m[3][2] - m[2][1] * m[1][2] * m[3][3] +
                            m[2][1] * m[1][3] * m[3][2] + m[3][1] * m[1][2] * m[2][3] - m[3][1] * m[1][3] * m[2][2]);
        ret[0][1] =
            one_over_det * (m[3][1] * m[0][3] * m[2][2] - m[3][1] * m[0][2] * m[2][3] - m[2][1] * m[0][3] * m[3][2] +
                            m[2][1] * m[0][2] * m[3][3] + m[0][1] * m[2][3] * m[3][2] - m[0][1] * m[2][2] * m[3][3]);
        ret[0][2] =
            one_over_det * (m[0][1] * m[1][2] * m[3][3] - m[0][1] * m[1][3] * m[3][2] - m[1][1] * m[0][2] * m[3][3] +
                            m[1][1] * m[0][3] * m[3][2] + m[3][1] * m[0][2] * m[1][3] - m[3][1] * m[0][3] * m[1][2]);
        ret[0][3] =
            one_over_det * (m[2][1] * m[0][3] * m[1][2] - m[2][1] * m[0][2] * m[1][3] - m[1][1] * m[0][3] * m[2][2] +
                            m[1][1] * m[0][2] * m[2][3] + m[0][1] * m[1][3] * m[2][2] - m[0][1] * m[1][2] * m[2][3]);
        ret[1][0] =
            one_over_det * (m[3][0] * m[1][3] * m[2][2] - m[3][0] * m[1][2] * m[2][3] - m[2][0] * m[1][3] * m[3][2] +
                            m[2][0] * m[1][2] * m[3][3] + m[1][0] * m[2][3] * m[3][2] - m[1][0] * m[2][2] * m[3][3]);
        ret[1][1] =
            one_over_det * (m[0][0] * m[2][2] * m[3][3] - m[0][0] * m[2][3] * m[3][2] - m[2][0] * m[0][2] * m[3][3] +
                            m[2][0] * m[0][3] * m[3][2] + m[3][0] * m[0][2] * m[2][3] - m[3][0] * m[0][3] * m[2][2]);
        ret[1][2] =
            one_over_det * (m[3][0] * m[0][3] * m[1][2] - m[3][0] * m[0][2] * m[1][3] - m[1][0] * m[0][3] * m[3][2] +
                            m[1][0] * m[0][2] * m[3][3] + m[0][0] * m[1][3] * m[3][2] - m[0][0] * m[1][2] * m[3][3]);
        ret[1][3] =
            one_over_det * (m[0][0] * m[1][2] * m[2][3] - m[0][0] * m[1][3] * m[2][2] - m[1][0] * m[0][2] * m[2][3] +
                            m[1][0] * m[0][3] * m[2][2] + m[2][0] * m[0][2] * m[1][3] - m[2][0] * m[0][3] * m[1][2]);
        ret[2][0] =
            one_over_det * (m[1][0] * m[2][1] * m[3][3] - m[1][0] * m[2][3] * m[3][1] - m[2][0] * m[1][1] * m[3][3] +
                            m[2][0] * m[1][3] * m[3][1] + m[3][0] * m[1][1] * m[2][3] - m[3][0] * m[1][3] * m[2][1]);
        ret[2][1] =
            one_over_det * (m[3][0] * m[0][3] * m[2][1] - m[3][0] * m[0][1] * m[2][3] - m[2][0] * m[0][3] * m[3][1] +
                            m[2][0] * m[0][1] * m[3][3] + m[0][0] * m[2][3] * m[3][1] - m[0][0] * m[2][1] * m[3][3]);
        ret[2][2] =
            one_over_det * (m[0][0] * m[1][1] * m[3][3] - m[0][0] * m[1][3] * m[3][1] - m[1][0] * m[0][1] * m[3][3] +
                            m[1][0] * m[0][3] * m[3][1] + m[3][0] * m[0][1] * m[1][3] - m[3][0] * m[0][3] * m[1][1]);
        ret[2][3] =
            one_over_det * (m[2][0] * m[0][3] * m[1][1] - m[2][0] * m[0][1] * m[1][3] - m[1][0] * m[0][3] * m[2][1] +
                            m[1][0] * m[0][1] * m[2][3] + m[0][0] * m[1][3] * m[2][1] - m[0][0] * m[1][1] * m[2][3]);
        ret[3][0] =
            one_over_det * (m[3][0] * m[1][2] * m[2][1] - m[3][0] * m[1][1] * m[2][2] - m[2][0] * m[1][2] * m[3][1] +
                            m[2][0] * m[1][1] * m[3][2] + m[1][0] * m[2][2] * m[3][1] - m[1][0] * m[2][1] * m[3][2]);
        ret[3][1] =
            one_over_det * (m[0][0] * m[2][1] * m[3][2] - m[0][0] * m[2][2] * m[3][1] - m[2][0] * m[0][1] * m[3][2] +
                            m[2][0] * m[0][2] * m[3][1] + m[3][0] * m[0][1] * m[2][2] - m[3][0] * m[0][2] * m[2][1]);
        ret[3][2] =
            one_over_det * (m[3][0] * m[0][2] * m[1][1] - m[3][0] * m[0][1] * m[1][2] - m[1][0] * m[0][2] * m[3][1] +
                            m[1][0] * m[0][1] * m[3][2] + m[0][0] * m[1][2] * m[3][1] - m[0][0] * m[1][1] * m[3][2]);
        ret[3][3] =
            one_over_det * (m[0][0] * m[1][1] * m[2][2] - m[0][0] * m[1][2] * m[2][1] - m[1][0] * m[0][1] * m[2][2] +
                            m[1][0] * m[0][2] * m[2][1] + m[2][0] * m[0][1] * m[1][2] - m[2][0] * m[0][2] * m[1][1]);
        return ret;
    }
};

#endif
