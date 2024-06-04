//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_MAT_MAKE_H_
#define _KTM_I_MAT_MAKE_H_

#include <utility>
#include "../../setup.h"
#include "../../traits/type_traits_ext.h"
#include "../../type/basic.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

namespace ktm
{
template<class Father, class Child>
struct imat_make;

template<class Father, size_t Row, size_t Col, typename T>
struct imat_make<Father, mat<Row, Col, T, std::enable_if_t<Row != Col>>> : Father
{
    using Father::Father;

    template<typename ...RowVs>
    static KTM_INLINE std::enable_if_t<sizeof...(RowVs) == Col && std::is_same_vs<vec<Row, T>, std::remove_const_t<std::remove_reference_t<RowVs>>...>, 
        mat<Row, Col, T>> from_row(RowVs&&... rows) noexcept
    {
        return from_row(std::make_index_sequence<Col>(), std::forward<RowVs>(rows)...);
    }
private:
    template<typename ...RowVs, size_t ...Ns>
    static KTM_INLINE mat<Row, Col, T> from_row(std::index_sequence<Ns...>, RowVs&&... rows) noexcept
    {
        mat<Row, Col, T> ret;
        size_t row_index;
        ((row_index = Ns, ret[row_index] = vec<Col, T>(rows[row_index]...)), ...);
        return ret;
    }
};

template<class Father, size_t N, typename T>
struct imat_make<Father, mat<N, N, T>> : Father
{
    using Father::Father;

    template<typename ...RowVs>
    static KTM_INLINE std::enable_if_t<sizeof...(RowVs) == N && std::is_same_vs<vec<N, T>, std::remove_const_t<std::remove_reference_t<RowVs>>...>, 
        mat<N, N, T>> from_row(RowVs&&... rows) noexcept
    {
        return from_row(std::make_index_sequence<N>(), std::forward<RowVs>(rows)...);
    }

    static KTM_INLINE mat<N, N, T> from_diag(const vec<N, T>& diag) noexcept
    {
        return from_diag(diag, std::make_index_sequence<N>());
    }

    static KTM_INLINE mat<N, N, T> from_eye() noexcept
    {
        static mat<N, N, T> eye = from_eye(std::make_index_sequence<N>());
        return eye;
    }
private:
    template<typename ...RowVs, size_t ...Ns>
    static KTM_INLINE mat<N, N, T> from_row(std::index_sequence<Ns...>, RowVs&&... rows) noexcept
    {
        mat<N, N, T> ret;
        size_t row_index;
        ((row_index = Ns, ret[row_index] = vec<N, T>(rows[row_index]...)), ...);
        return ret;
    }

    template<size_t ...Ns>
    static KTM_INLINE mat<N, N, T> from_diag(const vec<N, T>& diag, std::index_sequence<Ns...>) noexcept
    {
        mat<N, N, T> ret { };
        ((ret[Ns][Ns] = diag[Ns]), ...);
        return ret;
    }

    template<size_t ...Ns>
    static KTM_INLINE mat<N, N, T> from_eye(std::index_sequence<Ns...>) noexcept
    {
        mat<N, N, T> ret { };
        ((ret[Ns][Ns] = one<T>), ...);
        return ret;
    }
};

}

#endif