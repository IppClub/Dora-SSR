//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MAT_CALC_INL_
#define _KTM_MAT_CALC_INL_

#include "mat_calc_fwd.h"
#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"
#include "../../function/common.h"

template<size_t Row, size_t Col, typename T, typename Void>
struct ktm::detail::mat_opt_implement::mat_mul_vec
{
	using M = mat<Row, Col, T>;
    using ColV = vec<Col, T>;
    using RowV = vec<Row, T>;
    static KTM_INLINE ColV call(const M& m, const RowV& v) noexcept
    {
        return call(m, v, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE ColV call(const M& m, const RowV& v, std::index_sequence<Ns...>) noexcept
    {
        ColV ret;
        ret = ((m[Ns] * v[Ns]) + ...);
        return ret;
    }
};

template<size_t Row, size_t Col, typename T, typename Void>
struct ktm::detail::mat_opt_implement::vec_mul_mat
{
    using M = mat<Row, Col, T>;
    using ColV = vec<Col, T>;
    using RowV = vec<Row, T>;
    static KTM_INLINE RowV call(const ColV& v, const M& m) noexcept
    {
        return call(v, m, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE RowV call(const ColV& v, const M& m, std::index_sequence<Ns...>) noexcept
    {
        RowV ret;
        ((ret[Ns] = ktm::reduce_add(m[Ns] * v)), ...);
        return ret;
    }
};

template<size_t Row, size_t Col, typename T, typename Void>
struct ktm::detail::mat_opt_implement::mat_mul_mat
{
    using M = mat<Row, Col, T>;
    template<size_t U>
    using M2 = mat<U, Row, T>;
    template<size_t U>
    using RetM = mat<U, Col, T>;

    template<size_t U>
    static KTM_INLINE RetM<U> call(const M& m1 , const M2<U>& m2) noexcept
    {
        return call(m1, m2,  std::make_index_sequence<U>());
    }
private:
    template<size_t U, size_t ...Ns>
    static KTM_INLINE RetM<U> call(const M& m1 , const M2<U>& m2, std::index_sequence<Ns...>) noexcept
    {
        RetM<U> ret;
        ((ret[Ns] = mat_mul_vec<Row, Col, T>::call(m1, m2[Ns])), ...);
        return ret;
    }
};

template<size_t Row, size_t Col, typename T, typename Void>
struct ktm::detail::mat_opt_implement::add
{
	using M = mat<Row, Col, T>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        (((ret[Ns] = m1[Ns] + m2[Ns])), ...);
        return ret;
    }
};

template<size_t Row, size_t Col, typename T, typename Void>
struct ktm::detail::mat_opt_implement::minus
{
	using M = mat<Row, Col, T>;
    static KTM_INLINE M call(const M& m1, const M& m2) noexcept
    {
        return call(m1, m2, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE M call(const M& m1, const M& m2, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        (((ret[Ns] = m1[Ns] - m2[Ns])), ...);
        return ret;
    }
};

template<size_t Row, size_t Col, typename T, typename Void>
struct ktm::detail::mat_opt_implement::opposite
{
	using M = mat<Row, Col, T>;
    static KTM_INLINE M call(const M& m) noexcept
    {
        return call(m, std::make_index_sequence<Row>());
    }
private:
    template<size_t ...Ns>
    static KTM_INLINE M call(const M& m, std::index_sequence<Ns...>) noexcept
    {
        M ret;
        (((ret[Ns] = -m[Ns])), ...);
        return ret;
    }
};

#endif
