//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
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

template <class Father, class Child>
struct imat_make;

template <class Father, size_t Row, size_t Col, typename T>
struct imat_make<Father, mat<Row, Col, T, std::enable_if_t<Row != Col>>> : Father
{
    using Father::Father;

    template <typename... RowVs>
    static KTM_INLINE std::enable_if_t<sizeof...(RowVs) == Col && std::is_same_vs<vec<Row, T>, std::decay_t<RowVs>...>,
                                       mat<Row, Col, T>>
    from_row(RowVs&&... rows) noexcept
    {
        mat<Row, Col, T> ret;
        if constexpr (Row <= 4)
            from_row(ret, std::make_index_sequence<Row>(), std::forward<RowVs>(rows)...);
        else
        {
            for (int i = 0; i < Row; ++i)
                ret[i] = vec<Col, T>(rows[i]...);
        }
        return ret;
    }

private:
    template <typename... RowVs, size_t... Ns>
    static KTM_INLINE void from_row(mat<Row, Col, T>& ret, std::index_sequence<Ns...>, RowVs&&... rows) noexcept
    {
        size_t row_index;
        ((row_index = Ns, ret[row_index] = vec<Col, T>(rows[row_index]...)), ...);
    }
};

template <class Father, size_t N, typename T>
struct imat_make<Father, mat<N, N, T>> : Father
{
    using Father::Father;

    template <typename... RowVs>
    static KTM_INLINE
        std::enable_if_t<sizeof...(RowVs) == N && std::is_same_vs<vec<N, T>, std::decay_t<RowVs>...>, mat<N, N, T>>
        from_row(RowVs&&... rows) noexcept
    {
        mat<N, N, T> ret;
        if constexpr (N <= 4)
            from_row(ret, std::make_index_sequence<N>(), std::forward<RowVs>(rows)...);
        else
        {
            for (int i = 0; i < N; ++i)
                ret[i] = vec<N, T>(rows[i]...);
        }
        return ret;
    }

    static KTM_INLINE mat<N, N, T> from_diag(const vec<N, T>& diag) noexcept
    {
        mat<N, N, T> ret {};
        if constexpr (N <= 4)
            from_diag(ret, diag, std::make_index_sequence<N>());
        else
        {
            for (int i = 0; i < N; ++i)
                ret[i][i] = diag[i];
        }
        return ret;
    }

    static KTM_INLINE mat<N, N, T> from_eye() noexcept
    {
        mat<N, N, T> eye {};
        if constexpr (N <= 4)
            from_eye(eye, std::make_index_sequence<N>());
        else
        {
            for (int i = 0; i < N; ++i)
                eye[i][i] = one<T>;
        }
        return eye;
    }

private:
    template <typename... RowVs, size_t... Ns>
    static KTM_INLINE void from_row(mat<N, N, T>& ret, std::index_sequence<Ns...>, RowVs&&... rows) noexcept
    {
        size_t row_index;
        ((row_index = Ns, ret[row_index] = vec<N, T>(rows[row_index]...)), ...);
    }

    template <size_t... Ns>
    static KTM_INLINE void from_diag(mat<N, N, T>& ret, const vec<N, T>& diag, std::index_sequence<Ns...>) noexcept
    {
        ((ret[Ns][Ns] = diag[Ns]), ...);
    }

    template <size_t... Ns>
    static KTM_INLINE void from_eye(mat<N, N, T>& ret, std::index_sequence<Ns...>) noexcept
    {
        ((ret[Ns][Ns] = one<T>), ...);
    }
};

} // namespace ktm

#endif